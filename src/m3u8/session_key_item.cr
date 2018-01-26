module M3U8
  # KeyItem represents a set of EXT-X-SESSION-KEY attributes
  # https://tools.ietf.org/html/draft-pantos-http-live-streaming-20#page-33
  class SessionKeyItem
    include Concern
    include Encryptable

    # ```
    # text = %(#EXT-X-SESSION-KEY:METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")
    # SessionKeyItem.parse(text)
    # # => #<M3U8::SessionKeyItem......>
    # ```
    def self.parse(text)
      attributes = parse_attributes(text)
      new Encryptable.convert_key(attributes)
    end

    # ```
    # options = {
    #   method:              "AES-128",
    #   uri:                 "http://test.key",
    #   iv:                  "D512BBF",
    #   key_format:          "identity",
    #   key_format_versions: "1/3",
    # }
    # SessionKeyItem.new(options).to_s
    # # => %(#EXT-X-SESSION-KEY:METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")
    # ```
    def to_s
      "#EXT-X-SESSION-KEY:#{attributes_to_s}"
    end
  end
end
