module M3U8
  # MapItem represents a EXT-X-MAP tag which specifies how to obtain the Media
  # Initialization Section
  class MapItem
    include Concern

    property uri : String
    property byterange : ByteRange

    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        uri: params[:uri],
        byterange: params[:byterange]?
      )
    end

    def initialize(@uri, byterange = nil)
      @byterange = parse_byterange(byterange)
    end

    # def self.parse(text)
    #   attributes = parse_attributes(text)
    #   range_value = attributes['BYTERANGE']
    #   range = ByteRange.parse(range_value) unless range_value.nil?
    #   options = { uri: attributes['URI'], byterange: range }
    #   MapItem.new(options)
    # end

    def to_s
      %(#EXT-X-MAP:#{attributes.join(',')})
    end

    def attributes
      [
        uri_format,
        byterange_format
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
