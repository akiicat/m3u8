module M3U8
  # KeyItem represents a set of EXT-X-SESSION-KEY attributes
  # https://tools.ietf.org/html/draft-pantos-http-live-streaming-20#page-33
  class SessionKeyItem
    include Concern
    include Encryptable

    def self.parse(text)
      attributes = parse_attributes(text)
      new Encryptable.convert_key(attributes)
    end

    def to_s
      "#EXT-X-SESSION-KEY:#{attributes_to_s}"
    end
  end
end
