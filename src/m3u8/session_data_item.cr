module M3U8
  # `SessionDataItem` represents a set of attributes for the `EXT-X-SESSION-DATA` tag
  # used in HLS playlists.
  #
  # The `EXT-X-SESSION-DATA` tag (defined in [RFC 8216, Section 4.3.4.4](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.4))
  # is used to convey session-level metadata in an HLS Master Playlist. It can include various key-value
  # pairs such as the data identifier (*DATA-ID*), a human-readable value (*VALUE*), an optional URI
  # to more detailed data (*URI*), and a language code (*LANGUAGE*).
  #
  # Example tags:
  #
  # ```txt
  # #EXT-X-SESSION-DATA:DATA-ID="com.example.lyrics",URI="lyrics.json"
  # #EXT-X-SESSION-DATA:DATA-ID="com.example.title",LANGUAGE="en",VALUE="This is an example"
  # #EXT-X-SESSION-DATA:DATA-ID="com.example.title",LANGUAGE="es",VALUE="Este es un ejemplo"
  # ```
  #
  # According to [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216), each `EXT-X-SESSION-DATA`
  # tag MUST contain either a *VALUE* or a *URI* attribute, but not both. This implementation, however,
  # provides the flexibility to bypass that check.
  #
  # This class provides methods to parse such a tag from a text string, create a new instance using a
  # NamedTuple of parameters, and output the tag as a properly formatted string.
  class SessionDataItem
    include Concern

    # The unique identifier for the session data.
    #
    # According to [RFC 8216, Section 4.3.4.4](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.4), this attribute is required.
    # The value of *DATA-ID* is a quoted-string that identifies a
    # particular data value.  The *DATA-ID* should conform to a reverse
    # DNS naming convention, such as "com.example.movie.title"; however,
    # there is no central registration authority, so Playlist authors
    # should take care to choose a value that is unlikely to collide
    # with others.
    #
    # Example:
    #
    # ```txt
    # #EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title"
    # ```
    property data_id : String?

    # The `value` associated with the data identifier `data_id`.
    #
    # In [RFC 8216, Section 4.3.4.4](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.4),
    # *VALUE* is a quoted-string.  It contains the data identified by
    # *DATA-ID*.  If the *LANGUAGE* is specified, *VALUE* should contain a
    # human-readable string written in the specified language.
    #
    # Example:
    #
    # ```txt
    # #EXT-X-SESSION-DATA:DATA-ID="com.example.title",LANGUAGE="en",VALUE="This is an example"
    # ```
    property value : String?

    # An optional *URI* providing further details or related data.
    #
    # In [RFC 8216, Section 4.3.4.4](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.4),
    # the value is a quoted-string containing a *URI*.  The resource
    # identified by the *URI* MUST be formatted as JSON [RFC7159](https://datatracker.ietf.org/doc/html/rfc5646);
    # otherwise, clients may fail to interpret the resource.
    #
    # Example:
    #
    # ```txt
    # #EXT-X-SESSION-DATA:DATA-ID="com.example.lyrics",URI="lyrics.json"
    # ```
    property uri : String?

    # An optional language code for the data.
    #
    # In [RFC 8216, Section 4.3.4.4](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.4),
    # the value is a quoted-string containing a language tag [RFC5646](https://datatracker.ietf.org/doc/html/rfc5646)
    # that identifies the language of the *VALUE*.
    #
    # Example:
    #
    # ```txt
    # #EXT-X-SESSION-DATA:DATA-ID="com.example.title",LANGUAGE="en",VALUE="This is an example"
    # ```
    property language : String?

    # Parses a text line representing an `EXT-X-SESSION-DATA` tag and returns a new `SessionDataItem`.
    #
    # The tag line should include attributes such as *DATA-ID*, *VALUE*, *URI*, and *LANGUAGE*.
    #
    # Example:
    #
    # ```
    # text = %(#EXT-X-SESSION-DATA:DATA-ID="com.example.lyrics",URI="lyrics.json")
    # SessionDataItem.parse(text)
    # # => #<M3U8::SessionDataItem:0x7874fd4a85a0
    # #     @data_id="com.example.lyrics",
    # #     @language=nil,
    # #     @uri="lyrics.json",
    # #     @value=nil>
    #
    # text = %(#EXT-X-SESSION-DATA:DATA-ID="com.example.title",LANGUAGE="en",VALUE="This is an example")
    # SessionDataItem.parse(text)
    # # => #<M3U8::SessionDataItem:0x7874fd4a8330
    # #     @data_id="com.example.title",
    # #     @language="en",
    # #     @uri=nil,
    # #     @value="This is an example">
    #
    # text = %(#EXT-X-SESSION-DATA:DATA-ID="com.example.title",LANGUAGE="es",VALUE="Este es un ejemplo")
    # SessionDataItem.parse(text)
    # # => #<M3U8::SessionDataItem:0x7874fd4a80c0
    # #     @data_id="com.example.title",
    # #     @language="es",
    # #     @uri=nil,
    # #     @value="Este es un ejemplo">
    #
    # text = %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",VALUE="Test",URI="http://test",LANGUAGE="en")
    # SessionDataItem.parse(text)
    # # => #<M3U8::SessionDataItem:0x7874fd4b0ea0
    # #     @data_id="com.test.movie.title",
    # #     @language="en",
    # #     @uri="http://test",
    # #     @value="Test">
    # ```
    def self.parse(text)
      attributes = parse_attributes(text)
      new(
        data_id: attributes["DATA-ID"]?,
        value: attributes["VALUE"]?,
        uri: attributes["URI"]?,
        language: attributes["LANGUAGE"]?
      )
    end

    # Constructs a new `SessionDataItem` from a NamedTuple of parameters.
    #
    # The NamedTuple can include the following keys:
    #   - `data_id` (String): the unique identifier.
    #   - `value` (String): the associated value.
    #   - `uri` (String): the *URI* providing additional data.
    #   - `language` (String): the language code.
    #
    # Example:
    #
    # ```
    # options = {
    #   data_id:  "com.test.movie.title",
    #   value:    "Test",
    #   uri:      "http://test",
    #   language: "en",
    # }
    # SessionDataItem.new(options)
    # # => #<M3U8::SessionDataItem:0x794e57f25c30
    # #     @data_id="com.test.movie.title",
    # #     @language="en",
    # #     @uri="http://test",
    # #     @value="Test">
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        data_id: params[:data_id]?,
        value: params[:value]?,
        uri: params[:uri]?,
        language: params[:language]?
      )
    end

    # Initializes a new `SessionDataItem` instance with the given attributes.
    #
    # If no parameters are provided, the instance properties default to `nil`.
    #
    # Example:
    #
    # ```
    # SessionDataItem.new
    # # => #<M3U8::SessionDataItem:0x79dcf3b0f9c0
    # #     @data_id=nil,
    # #     @language=nil,
    # #     @uri=nil,
    # #     @value=nil>
    #
    # SessionDataItem.new(data_id: "com.test.movie.title", value: "Test", uri: "http://test", language: "en")
    # # => #<M3U8::SessionDataItem:0x78ba0d6b4420
    # #     @data_id="com.test.movie.title",
    # #     @language="en",
    # #     @uri="http://test",
    # #     @value="Test">
    # ```
    def initialize(@data_id = nil, @value = nil, @uri = nil, @language = nil)
    end

    # Returns the string representation of the `EXT-X-SESSION-DATA` tag.
    #
    # The output is generated by joining the formatted attributes with commas,
    # and then prefixing the result with `#EXT-X-SESSION-DATA:`.
    #
    # Example:
    #
    # ```txt
    # options = {
    #   data_id:  "com.test.movie.title",
    #   value:    "Test",
    #   uri:      "http://test",
    #   language: "en",
    # }
    # SessionDataItem.new(options).to_s
    # # => "#EXT-X-SESSION-DATA:DATA-ID=\"com.test.movie.title\",VALUE=\"Test\",URI=\"http://test\",LANGUAGE=\"en\""
    # ```
    def to_s
      "#EXT-X-SESSION-DATA:#{attributes.join(',')}"
    end

    private def attributes
      [
        data_id_format,
        value_format,
        uri_format,
        language_format,
      ].compact
    end

    private def data_id_format
      %(DATA-ID="#{data_id}")
    end

    private def value_format
      %(VALUE="#{value}") unless value.nil?
    end

    private def uri_format
      %(URI="#{uri}") unless uri.nil?
    end

    private def language_format
      %(LANGUAGE="#{language}") unless language.nil?
    end
  end
end
