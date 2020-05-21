module Argentum
  module JSONPath
    module NilResult
      def nil?
        true
      end

      def array?
        false
      end
    
      def hash?
        false
      end

      def method_missing(name, *args, &block)
        JSONPath.new nil
      end
    end

    module HashResult
      def array?
        false
      end

      def hash?
        true
      end

      def [](name)
        JSONPath.new super(name)
      end

      def method_missing(name, *args, &block)
        result = JSONPath.new self[name.to_s]
        yield result if block_given? && result
        result
      end
    end

    module ArrayResult
      def array?
        true
      end

      def hash?
        false
      end

      def each(&block)
        super { |i| yield JSONPath.new(i) }
      end

      def map(&block)
        super { |i| yield JSONPath.new(i) }
      end

      def select(&block)
        super { |i| yield JSONPath.new(i) }
      end

      def method_missing(name, *args, &block)
        JSONPath.new nil
      end
    end

    def self.new(json)
      case json
        when Hash     then json.extend(HashResult)
        when Array    then json.extend(ArrayResult)
        when NilClass then json.extend(NilResult)
        else json
      end
    end

  end
end
