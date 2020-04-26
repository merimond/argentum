module Argentum
  module MultiLogger
    class MultiIO
      def initialize(*targets)
        @targets = targets
      end

      def write(*args)
        @targets.each { |t| t.write(*args) }
      end

      def close
        @targets.each(&:close)
      end
    end

    def self.to_file(name)
      name = "%s-%s.log" % [Time.now.strftime("%F"), name]
      file = File.open File.join(Dir.pwd, "log", name), "a"
      ::Logger.new MultiIO.new(STDOUT, file)
    end
  end
end
