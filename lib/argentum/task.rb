module Argentum
  class Task
    attr_reader :logger, :name

    @@db_config = nil

    def self.set_db_config(value)
      @@db_config = value
    end

    def self.start(*args)
      new(*args) do |task|
        task.start
        yield task if block_given?
        task.complete
      end
    end

    def initialize(name)
      @name = name
      @logger = MultiLogger.new

      if defined?(Rails)
        @logger.add FileLogger.new(name)
      end

      if @@db_config.is_a?(Hash)
        @logger.add DatabaseLogger.new(name, @@db_config)
      end

      #if !defined?(Rails) || Rails.env != "production"
        @logger.add StdOutLogger.new(name)
      #end

      if ENV["LOG_ACTIVE_RECORD"] == "true"
        ActiveRecord::Base.logger = logger
      end

      if block_given?
        yield self
      end
    end

    def start
      @started_at = Time.now
      logger.info "%s started" % name
    end

    def complete
      logger.info "%s completed" % name
      logger.close
    end

    def error(*args, &block)
      logger.warn(*args, &block)
    end

    def info(*args, &block)
      logger.info(*args, &block)
    end

    def warn(*args, &block)
      logger.warn(*args, &block)
    end

    def been_running_longer_than?(secs)
      @started_at.nil? ? false : (Time.now - @started_at > secs.to_i)
    end

    def log_operation_results(operation)
      operation.warnings_as_array.each do |w|
        self.warn(w)
      end
      operation.errors_as_array.each do |e|
        self.error(e)
      end
      operation.info_as_array.each do |e|
        self.info(e)
      end
      operation
    end

    def run_and_log(klass, *args)
      operation = klass.call(*args)
      log_operation_results(operation)
      operation.result
    end

    def run_sql(sql)
      ActiveRecord::Base.connection.execute(sql)
    end

    def run_sql_and_log_count(message, sql)
      self.info(message % run_sql(sql).cmd_tuples)
    end
  end
end
