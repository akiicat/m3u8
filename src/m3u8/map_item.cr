module M3U8
  # `MapItem` represents an `EXT-X-MAP` tag in an HLS playlist.
  #
  # The `EXT-X-MAP` tag (defined in [RFC 8216, Section 4.3.2.5](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.2.5))
  # specifies how to obtain the Media Initialization Section, which is required to parse the Media Segments.
  #
  # For example, a valid `EXT-X-MAP` tag might look like:
  #
  # ```txt
  # #EXT-X-MAP:URI="frelo/prog_index.m3u8",BYTERANGE="4500@600"
  # ```
  #
  # The `MapItem` class stores the following properties:
  #   - `uri` (String): the URI for the Media Initialization Section.
  #   - `byterange` (`ByteRange`): the byte range indicating which part of the resource to use.
  class MapItem
    include Concern

    # The URI for the Media Initialization Section.
    property uri : String

    # The byte range indicating which part of the resource to use.
    property byterange : ByteRange

    # Parses a string representing an `EXT-X-MAP` tag and returns a new `MapItem` instance.
    #
    # The method extracts attributes from the tag line using `parse_attributes` and
    # converts the `byterange` value using `ByteRange.parse`.
    #
    # Example:
    #
    # ```txt
    # text = %(#EXT-X-MAP:URI="frelo/prog_index.m3u8",BYTERANGE="4500@600")
    # MapItem.parse(text)
    # # => #<M3U8::MapItem:0x79d016ab9f60
    # #     @byterange=#<M3U8::ByteRange:0x79d016a8ee40 @length=4500, @start=600>,
    # #     @uri="frelo/prog_index.m3u8">
    # ```
    def self.parse(text)
      params = parse_attributes(text)
      new(
        uri: params["URI"],
        byterange: ByteRange.parse(params["BYTERANGE"]?),
      )
    end

    # Constructs a new `MapItem` instance from a NamedTuple of parameters.
    #
    # The NamedTuple can include the following keys:
    #   - `:uri` (String): the URI for the initialization section.
    #   - `:byterange` (can be a Hash, a NamedTuple, a `ByteRange` instance, or a String like "4500@600").
    #
    # Examples:
    #
    # ```
    # options = {
    #   uri:       "frelo/prog_index.m3u8",
    #   byterange: {length: 4500, start: 600},
    # }
    # MapItem.new(options)
    # # => #<M3U8::MapItem:0x7adc917c08a0
    # #     @byterange=#<M3U8::ByteRange:0x7adc91795d50 @length=4500, @start=600>,
    # #     @uri="frelo/prog_index.m3u8">
    #
    # options = {
    #   uri:       "frelo/prog_index.m3u8",
    #   byterange: ByteRange.new(length: 4500, start: 600),
    # }
    # MapItem.new(options)
    # # => #<M3U8::MapItem:0x7adc917c01e0
    # #     @byterange=#<M3U8::ByteRange:0x7adc91795c60 @length=4500, @start=600>,
    # #     @uri="frelo/prog_index.m3u8">
    #
    # options = {
    #   uri:       "frelo/prog_index.m3u8",
    #   byterange: "4500@600",
    # }
    # MapItem.new(options)
    # # => #<M3U8::MapItem:0x7adc917c1ba0
    # #     @byterange=#<M3U8::ByteRange:0x7adc91795b70 @length=4500, @start=600>,
    # #     @uri="frelo/prog_index.m3u8">
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        uri: params[:uri],
        byterange: params[:byterange]?
      )
    end

    # Initializes a new `MapItem` instance.
    #
    # Accepts a `uri` as the first parameter and an optional `byterange` parameter,
    # which is passed to `ByteRange.parse`.
    #
    # Examples:
    #
    # ```
    # uri = "frelo/prog_index.m3u8"
    # byterange = "4500@600"
    # MapItem.new(uri)
    # MapItem.new(uri: uri)
    # # => #<M3U8::MapItem:0x789a5325c760
    # #     @byterange=#<M3U8::ByteRange:0x789a5322e8a0 @length=nil, @start=nil>,
    # #     @uri="frelo/prog_index.m3u8">
    #
    # MapItem.new(uri, byterange)
    # MapItem.new(uri: uri, byterange: byterange)
    # # => #<M3U8::MapItem:0x789a5325c0a0
    # #     @byterange=#<M3U8::ByteRange:0x789a5322e7b0 @length=4500, @start=600>,
    # #     @uri="frelo/prog_index.m3u8">
    # ```
    def initialize(@uri, byterange = nil)
      @byterange = ByteRange.parse(byterange)
    end

    # Returns the string representation of the `EXT-X-MAP` tag.
    #
    # It concatenates the formatted `uri` and `byterange` attributes, separated by commas,
    # and prefixes the result with `#EXT-X-MAP:`.
    #
    # Example:
    #
    # ```txt
    # options = {
    #   uri:       "frelo/prog_index.m3u8",
    #   byterange: "4500@600",
    # }
    # MapItem.new(options).to_s
    # # => #EXT-X-MAP:URI="frelo/prog_index.m3u8",BYTERANGE="4500@600"
    # ```
    def to_s
      %(#EXT-X-MAP:#{attributes.join(',')})
    end

    private def attributes
      [
        uri_format,
        byterange_format,
      ].compact
    end

    private def uri_format
      %(URI="#{uri}")
    end

    private def byterange_format
      %(BYTERANGE="#{byterange.to_s}") unless byterange.empty?
    end
  end
end
