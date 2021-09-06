
module Argentum
  class Task
    class FileLogger

      def initialize(name)
        name = name.gsub(":", "-").gsub("_", "-")
        time = Time.now.strftime("%F")
        path = "#{time}-#{name}.log" 

        dir  = File.join(Dir.pwd, "log")
        path = File.join(dir, path)

        unless File.exists?(dir)
          Dir.mkdir(dir)
        end

        unless File.directory?(dir)
          throw "#{folder} is not a valid directory"
        end

        @logger = Logger.new(path)
      end

      def method_missing(name, *args, &block)
        @logger.send(name, *args, &block)
      end

    end
  end
end

