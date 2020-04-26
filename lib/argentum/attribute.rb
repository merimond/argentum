module Argentum
  module Attribute

    DEFAULT_SANITIZE_OPTIONS = {
      :lowercase           => false,
      :strip_spaces        => true,
      :nulify_if_empty     => true,
      :strip_double_spaces => true,
      :nulify_if_not_uuid  => false,
      :decode_entities     => false
    }

    def self.sanitize(value, opts = {})
      options = DEFAULT_SANITIZE_OPTIONS.merge(opts)
      result = value.to_s

      if options[:strip_spaces]
        result = result.to_s.strip
      end
      if options[:lowercase]
        result = result.to_s.downcase
      end
      if options[:strip_double_spaces]
        result = result.to_s.gsub(/\s{2,}/," ")
      end
      if options[:decode_entities]
        result = Addressable::URI.unencode(HTMLEntities.new.decode(result)).scrub
      end
      if options[:nulify_if_not_uuid]
        result = nil unless UUID.valid?(result)
      end
      if options[:nulify_if_empty]
        result = nil if result.empty?
      end

      result
    end

  end
end
