module Argentum
  class Task
    class StdOutLogger

      def initialize(name)
        @logger = Logger.new(STDOUT)
      end

      def close
        # NOOP
      end

      def method_missing(name, *args, &block)
        @logger.send(name, *args, &block)
      end

    end
  end
end
