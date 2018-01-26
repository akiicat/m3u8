module M3U8
  # MediaItem represents a set of EXT-X-MEDIA attributes
  class MediaItem
    include Concern

    property type : String?
    property group_id : String?
    property language : String?
    property assoc_language : String?
    property name : String?
    property uri : String?
    property autoselect : Bool?
    property default : Bool?
    property forced : Bool?
    property instream_id : String?
    property characteristics : String?
    property channels : String?

    def self.parse(text)
      attributes = parse_attributes(text)
      new(
        type: attributes["TYPE"]?,
        group_id: attributes["GROUP-ID"]?,
        language: attributes["LANGUAGE"]?,
        assoc_language: attributes["ASSOC-LANGUAGE"]?,
        name: attributes["NAME"]?,
        autoselect: parse_boolean(attributes["AUTOSELECT"]?),
        default: parse_boolean(attributes["DEFAULT"]?),
        forced: parse_boolean(attributes["FORCED"]?),
        uri: attributes["URI"]?,
        instream_id: attributes["INSTREAM-ID"]?,
        characteristics: attributes["CHARACTERISTICS"]?,
        channels: attributes["CHANNELS"]?,
      )
    end

    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        type: params[:type]?,
        group_id: params[:group_id]?,
        language: params[:language]?,
        assoc_language: params[:assoc_language]?,
        name: params[:name]?,
        uri: params[:uri]?,
        autoselect: params[:autoselect]?,
        default: params[:default]?,
        forced: params[:forced]?,
        instream_id: params[:instream_id]?,
        characteristics: params[:characteristics]?,
        channels: params[:channels]?,
      )
    end

    def initialize(@type = nil, @group_id = nil, @language = nil, @assoc_language = nil, @name = nil,
                   @uri = nil, @autoselect = nil, @default = nil, @forced = nil, @instream_id = nil,
                   @characteristics = nil, @channels = nil)
    end

    def to_s
      "#EXT-X-MEDIA:#{attributes.join(',')}"
    end

    private def attributes
      [
        type_format,
        group_id_format,
        language_format,
        assoc_language_format,
        name_format,
        autoselect_format,
        default_format,
        uri_format,
        forced_format,
        instream_id_format,
        characteristics_format,
        channels_format,
      ].compact
    end

    private def type_format
      %(TYPE=#{type})
    end

    private def group_id_format
      %(GROUP-ID="#{group_id}")
    end

    private def language_format
      %(LANGUAGE="#{language}") unless language.nil?
    end

    private def assoc_language_format
      %(ASSOC-LANGUAGE="#{assoc_language}") unless assoc_language.nil?
    end

    private def name_format
      %(NAME="#{name}")
    end

    private def uri_format
      %(URI="#{uri}") unless uri.nil?
    end

    private def autoselect_format
      %(AUTOSELECT=#{parse_yes_no(autoselect)}) unless autoselect.nil?
    end

    private def default_format
      %(DEFAULT=#{parse_yes_no(default)}) unless default.nil?
    end

    private def forced_format
      %(FORCED=#{parse_yes_no(forced)}) unless forced.nil?
    end

    private def instream_id_format
      %(INSTREAM-ID="#{instream_id}") unless instream_id.nil?
    end

    private def characteristics_format
      %(CHARACTERISTICS="#{characteristics}") unless characteristics.nil?
    end

    private def channels_format
      %(CHANNELS="#{channels}") unless channels.nil?
    end
  end
end
