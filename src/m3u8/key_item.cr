module M3U8
  # `KeyItem` represents a set of `EXT-X-KEY` attributes used for specifying
  # the encryption parameters of Media Segments in an HLS playlist.
  #
  # In HLS, as defined in [RFC 8216, Section 4.3.2.4](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.2.4),
  # the `EXT-X-KEY` tag specifies how Media Segments are encrypted. It includes
  # attributes such as `METHOD`, `URI`, `IV`, `KEYFORMAT`, and `KEYFORMATVERSIONS`.
  #
  # Example of a key tag:
  #
  # ```txt
  # #EXT-X-KEY:METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3"
  # ```
  #
  # This class combines the functionality provided by the `Concern` and `Encryptable`
  # modules to parse and format these encryption key attributes.
  class KeyItem
    include Concern
    include Encryptable

    # Parses a text line representing an `EXT-X-KEY` tag and returns a new `KeyItem`.
    #
    # The method extracts the attribute list from the tag line, converts the keys using
    # `Encryptable.convert_key`, and initializes a new instance.
    #
    # Example:
    #
    # ```txt
    # text = %(#EXT-X-KEY:METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3")
    # KeyItem.parse(text)
    # # => #<M3U8::KeyItem:0x7f5ceff07a80
    #       @iv="D512BBF",
    #       @key_format="identity",
    #       @key_format_versions="1/3",
    #       @method="AES-128",
    #       @uri="http://test.key">
    # ```
    def self.parse(text)
      attributes = parse_attributes(text)
      new Encryptable.convert_key(attributes)
    end

    # Returns the string representation of the `EXT-X-KEY` tag.
    #
    # It prefixes the formatted key attributes with `#EXT-X-KEY:`.
    #
    # Example:
    #
    # ```txt
    # options = {
    #   method:              "AES-128",
    #   uri:                 "http://test.key",
    #   iv:                  "D512BBF",
    #   key_format:          "identity",
    #   key_format_versions: "1/3",
    # }
    # KeyItem.new(options).to_s
    # # => "#EXT-X-KEY:METHOD=AES-128,URI=\"http://test.key\",IV=D512BBF,KEYFORMAT=\"identity\",KEYFORMATVERSIONS=\"1/3\""
    # ```
    def to_s
      "#EXT-X-KEY:#{attributes_to_s}"
    end
  end
end
