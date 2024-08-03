# frozen_string_literal: true

class GptFunction
  class SimpleQueue
    def initialize
      @queue = []
    end

    def enqueue(value)
      @queue << value
      true
    end

    def dequeue
      @queue.shift
    end
  end
end
