module Argentum
  module UUID
    FORMAT = /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/

    def self.valid?(id)
      id.instance_of?(String) ? id.match(FORMAT) : false
    end
  end
end
