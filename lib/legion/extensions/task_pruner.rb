require 'legion/extensions/task_pruner/version'

module Legion
  module Extensions
    module TaskPruner
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core

      def self.data_required?
        true
      end

      def data_required?
        true
      end
    end
  end
end
