module M3U8
  # SessionDataItem represents a set of EXT-X-SESSION-DATA attributes
  class SessionDataItem
    include Concern

    property data_id : String?
    property value : String?
    property uri : String?
    property language : String?

    # ```
    # text = %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",VALUE="Test",URI="http://test",LANGUAGE="en")
    # SessionDataItem.parse(text) # => #<M3U8::SessionDataItem......>
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

    # ```
    # options = {
    #   data_id:  "com.test.movie.title",
    #   value:    "Test",
    #   uri:      "http://test",
    #   language: "en",
    # }
    # SessionDataItem.new(options)
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        data_id: params[:data_id]?,
        value: params[:value]?,
        uri: params[:uri]?,
        language: params[:language]?
      )
    end

    # ```
    # SessionDataItem.new
    # ```
    def initialize(@data_id = nil, @value = nil, @uri = nil, @language = nil)
    end

    # ```
    # options = {
    #   data_id:  "com.test.movie.title",
    #   value:    "Test",
    #   uri:      "http://test",
    #   language: "en",
    # }
    # SessionDataItem.new(options).to_s
    # # => %(#EXT-X-SESSION-DATA:DATA-ID="com.test.movie.title",) \
    # %(VALUE="Test",URI="http://test",LANGUAGE="en")
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
