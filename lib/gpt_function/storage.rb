# frozen_string_literal: true

class GptFunction
  module Storage
    class << self
      def batch_storage=(value)
        # 檢查 value 有實作 enqueue 方法
        raise "Invalid batch storage: should respond to #enqueue" unless value.respond_to?(:enqueue)

        # 檢查 value 有實作 dequeue 方法
        raise "Invalid batch storage: should respond to #dequeue" unless value.respond_to?(:dequeue)
        @batch_storage = value
      end

      def batch_storage
        @batch_storage
      end
    end
  end
end
