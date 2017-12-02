module M3U8
  # KeyItem represents a set of EXT-X-SESSION-KEY attributes
  class SessionKeyItem

    include Encryptable

    def initialize(params = NamedTuple.new)
      options = convert_key_names(params)
      pp params
    end

    # def self.parse(text)
    #   attributes = parse_attributes(text)
    #   SessionKeyItem.new(attributes)
    # end

    def to_s
      "#EXT-X-SESSION-KEY:#{attributes_to_s}"
    end
  end
end
