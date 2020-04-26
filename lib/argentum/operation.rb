module Argentum
  class Operation
    def self.call(params = {}, &block)
      self.new.call(params, &block)
    end

    attr_reader :errors
    attr_reader :info
    attr_reader :warnings
    attr_reader :result

    def initialize(*args)
      @result   = nil
      @info     = {}
      @errors   = {}
      @warnings = {}
      if block_given?
        yield self
      end
    end

    def call(params = {}, &block)
      @result = execute(params)
      if success? && block_given?
        yield @result
      end
      self
    end

    def whitelist(params, list)
      params.select { |k,v| list.include?(k.to_s) }
    end

    def run(operation, supress_errors_with_warning: false, save_errors_for_attribute: nil, **params)
      result = operation.call(params) do |result|
        yield result if block_given?
      end

      # Nothing to do in case of success
      if result.success?
        return result
      end

      # Skip errors and add a warning
      if supress_errors_with_warning.is_a?(String)
        warning! supress_errors_with_warning; return result
      end

      # Copy errors
      result.errors.each do |key, errors|
        errors.each { |error| error!(error, save_errors_for_attribute || key) }
      end

      # Return instance
      result
    end

    def validate_and_save_model!(model)
      # Nothing to do if model is valid
      if model.valid?
        model.save if model.changed?
        return model
      end

      # Copy errors
      model.errors.to_hash(true).each do |key, errors|
        errors.each { |error| error!(error, key) }
      end

      # Return instance
      model
    end

    def warning!(message, key = :base)
      key = key.to_sym
      unless @warnings.key?(key)
        @warnings[key] = []
      end
      @warnings[key].push(message)
      self
    end

    alias_method :warn!, :warning!

    def error!(message, key = :base)
      key = key.to_sym
      unless @errors.key?(key)
        @errors[key] = []
      end
      @errors[key].push(message)
      self
    end

    def info!(message, key = :base)
      key = key.to_sym
      unless @info.key?(key)
        @info[key] = []
      end
      @info[key].push(message)
      self
    end

    def info_as_array
      info.values.flatten
    end

    def info_as_string
      info_as_array.join(". ")
    end

    def errors_as_array
      errors.values.flatten
    end

    def errors_as_string
      errors_as_array.join(". ")
    end

    def warnings_as_array
      warnings.values.flatten
    end

    def warnings_as_string
      warnings_as_array.join(". ")
    end

    def success?
      errors.empty?
    end

    def failure?
      not success?
    end

    def has_info?
      not info.empty?
    end

    def has_warnings?
      not warnings.empty?
    end

  end
end
