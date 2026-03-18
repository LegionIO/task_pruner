# frozen_string_literal: true

module Legion
  module Extensions
    module TaskPruner
      module Runners
        module Prune
          def find_expired(age: 31, limit: 1000, status: ['task.completed'], **)
            log.debug("purging old completed tasks with an age > #{age} days, limit: #{limit}")
            cutoff = Time.now - (age * 86_400)
            dataset = Legion::Data::Model::Task
                      .where(Sequel.lit('created <= ?', cutoff))
                      .limit(limit)
            dataset = dataset.where(status: status) unless ['*', nil, ''].include?(status)
            count = dataset.count
            log.debug("Deleting #{count} records") if count.positive?
            dataset.delete
            { success: true, deleted: count }
          end

          def delete_task(task_id:, **)
            task = Legion::Data::Model::Task[task_id]
            return { success: false, error: 'task not found' } unless task

            task.delete
            { success: true, task_id: task_id }
          end

          def expire_queued(age: 1, limit: 10, **)
            cutoff = Time.now - (age * 86_400)
            dataset = Legion::Data::Model::Task
                      .where(status: ['conditioner.queued', 'transformer.queued', 'task.queued'])
                      .where(Sequel.lit('created <= ?', cutoff))
                      .limit(limit)
            count = dataset.count
            dataset.update(status: 'task.expired') if count.positive?
            { success: true, expired: count }
          end

          include Legion::Extensions::Helpers::Task if defined?(Legion::Extensions::Helpers::Task)
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)
        end
      end
    end
  end
end
