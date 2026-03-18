# frozen_string_literal: true

require 'spec_helper'

# Stub Sequel.lit for parameterized SQL expressions
module Sequel
  LitCondition = Struct.new(:sql, :args)

  def self.lit(sql, *args)
    LitCondition.new(sql, args)
  end
end

# Stub Legion::Data::Model::Task with a Sequel-like dataset API
module Legion # rubocop:disable Style/OneClassPerFile
  module Data
    module Model
      class Task
        class << self
          attr_accessor :records

          def reset!
            @records = []
            @last_dataset = nil
          end

          def where(conditions = nil, &block)
            ds = Dataset.new(@records)
            ds = ds.filter_block(&block) if block
            ds = ds.filter_hash(conditions) if conditions.is_a?(Hash)
            ds = ds.filter_lit(conditions) if conditions.is_a?(Sequel::LitCondition)
            ds
          end

          def [](id)
            @records.find { |r| r[:id] == id }
          end
        end

        self.records = []
      end

      class Dataset
        attr_reader :data

        def initialize(records)
          @data = records.dup
          @limit_val = nil
        end

        def where(conditions = nil, &block)
          ds = dup_with(@data)
          ds = ds.filter_block(&block) if block
          ds = ds.filter_hash(conditions) if conditions.is_a?(Hash)
          ds = ds.filter_lit(conditions) if conditions.is_a?(Sequel::LitCondition)
          ds
        end

        def limit(count)
          ds = dup_with(@data)
          ds.instance_variable_set(:@limit_val, count)
          ds
        end

        def count
          limited_data.size
        end

        def delete
          ids = limited_data.map { |r| r[:id] }
          Task.records.reject! { |r| ids.include?(r[:id]) }
          ids.size
        end

        def update(attrs)
          limited_data.each do |record|
            actual = Task.records.find { |r| r[:id] == record[:id] }
            attrs.each { |k, v| actual[k] = v } if actual
          end
        end

        def filter_hash(conditions)
          @data = @data.select do |r|
            conditions.all? do |k, v|
              v.is_a?(Array) ? v.include?(r[k]) : r[k] == v
            end
          end
          self
        end

        def filter_block(&)
          @data = @data.select(&)
          self
        end

        def filter_lit(condition)
          return self unless condition.sql.include?('created <= ?')

          cutoff = condition.args.first
          @data = @data.select { |r| r[:created] <= cutoff }
          self
        end

        private

        def limited_data
          @limit_val ? @data.first(@limit_val) : @data
        end

        def dup_with(records)
          ds = self.class.new(records)
          ds.instance_variable_set(:@limit_val, @limit_val)
          ds
        end
      end
    end
  end
end

# Stub the log method
module LogStub # rubocop:disable Style/OneClassPerFile
  def log
    @log ||= Class.new do
      def debug(_msg) = nil
    end.new
  end
end

require 'legion/extensions/task_pruner/runners/prune'

RSpec.describe Legion::Extensions::TaskPruner::Runners::Prune do
  let(:runner) { Object.new.extend(described_class).extend(LogStub) }
  let(:old_time) { Time.now - (32 * 86_400) } # 32 days ago
  let(:recent_time) { Time.now - 3600 }        # 1 hour ago
  let(:stuck_time) { Time.now - (2 * 86_400) } # 2 days ago

  before { Legion::Data::Model::Task.reset! }

  describe '#find_expired' do
    before do
      Legion::Data::Model::Task.records = [
        { id: 1, status: 'task.completed', created: old_time },
        { id: 2, status: 'task.completed', created: old_time },
        { id: 3, status: 'task.completed', created: recent_time },
        { id: 4, status: 'task.failed', created: old_time }
      ]
    end

    it 'deletes old completed tasks' do
      result = runner.find_expired(age: 31)
      expect(result[:success]).to be true
      expect(result[:deleted]).to eq(2)
    end

    it 'respects the limit parameter' do
      result = runner.find_expired(age: 31, limit: 1)
      expect(result[:deleted]).to eq(1)
    end

    it 'does not delete recent tasks' do
      runner.find_expired(age: 31)
      remaining_ids = Legion::Data::Model::Task.records.map { |r| r[:id] }
      expect(remaining_ids).to include(3)
    end

    it 'applies the status filter' do
      result = runner.find_expired(age: 31, status: ['task.completed'])
      expect(result[:deleted]).to eq(2)
      remaining = Legion::Data::Model::Task.records
      expect(remaining.map { |r| r[:id] }).to include(4)
    end

    it 'skips status filter with wildcard' do
      result = runner.find_expired(age: 31, status: '*')
      expect(result[:deleted]).to eq(3)
    end

    it 'returns zero when nothing matches' do
      result = runner.find_expired(age: 365)
      expect(result[:deleted]).to eq(0)
    end
  end

  describe '#delete_task' do
    before do
      Legion::Data::Model::Task.records = [
        { id: 10, status: 'task.completed', created: old_time, delete: -> { true } }
      ]
    end

    it 'deletes the specified task' do
      record = Legion::Data::Model::Task.records.first
      allow(record).to receive(:delete)
      result = runner.delete_task(task_id: 10)
      expect(result[:success]).to be true
      expect(result[:task_id]).to eq(10)
    end

    it 'returns error for nonexistent task' do
      result = runner.delete_task(task_id: 999)
      expect(result[:success]).to be false
      expect(result[:error]).to include('not found')
    end
  end

  describe '#expire_queued' do
    before do
      Legion::Data::Model::Task.records = [
        { id: 20, status: 'conditioner.queued', created: stuck_time },
        { id: 21, status: 'task.queued', created: stuck_time },
        { id: 22, status: 'transformer.queued', created: recent_time },
        { id: 23, status: 'task.running', created: stuck_time }
      ]
    end

    it 'marks stuck queued tasks as expired' do
      result = runner.expire_queued(age: 1)
      expect(result[:success]).to be true
      expect(result[:expired]).to eq(2)
    end

    it 'updates status to task.expired' do
      runner.expire_queued(age: 1)
      record = Legion::Data::Model::Task.records.find { |r| r[:id] == 20 }
      expect(record[:status]).to eq('task.expired')
    end

    it 'does not expire recently queued tasks' do
      runner.expire_queued(age: 1)
      record = Legion::Data::Model::Task.records.find { |r| r[:id] == 22 }
      expect(record[:status]).to eq('transformer.queued')
    end

    it 'does not expire non-queued tasks' do
      runner.expire_queued(age: 1)
      record = Legion::Data::Model::Task.records.find { |r| r[:id] == 23 }
      expect(record[:status]).to eq('task.running')
    end

    it 'returns zero when nothing stuck' do
      result = runner.expire_queued(age: 365)
      expect(result[:expired]).to eq(0)
    end
  end
end
