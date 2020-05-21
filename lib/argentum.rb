require "htmlentities"
require "addressable/uri"

require "argentum/attribute"
require "argentum/json_path"
require "argentum/operation"
require "argentum/multi_logger"
require "argentum/task"
require "argentum/uuid"

module Argentum

  def self.attribute(*args, &block)
    Attribute.sanitize(*args, &block)
  end

  def self.logger(*args, &block)
    MultiLogger.to_file(*args, &block)
  end

  def self.task(*args, &block)
    Task.start(*args, &block)
  end

  def self.uuid?(*args, &block)
    UUID.valid?(*args, &block)
  end

end
