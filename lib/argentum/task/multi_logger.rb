module Argentum
  class Task
    class MultiLogger

      def initialize(*loggers)
        @loggers = loggers
      end

      def add(logger)
        @loggers.push(logger)
      end

      def method_missing(name, *args, &block)
        @loggers.each { |logger| logger.send(name, *args, &block) }
      end

    end
  end
end
