module M3U8
  # KeyItem represents a set of EXT-X-KEY attributes
  class KeyItem
    include Concern
    include Encryptable

    # ```
    # text = %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")
    # KeyItem.parse(text)
    # # => #<M3U8::KeyItem......>
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
    # KeyItem.new(options).to_s
    # # => %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")
    # ```
    def to_s
      "#EXT-X-KEY:#{attributes_to_s}"
    end
  end
end
