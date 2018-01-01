module M3U8
  # Encapsulates logic common to encryption key tags
  module Encryptable
    property method : String
    property uri : String?
    property iv : String?
    property key_format : String?
    property key_format_versions : String?

    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        method: params[:method],
        uri: params[:uri]?,
        iv: params[:iv]?,
        key_format: params[:key_format]?,
        key_format_versions: params[:key_format_versions]?
      )
    end

    def initialize(@method = "",
                   @uri = nil,
                   @iv = nil,
                   @key_format = nil,
                   @key_format_versions = nil)
    end

    def attributes_to_s
      attributes.join(',')
    end

    def attributes
      [
        method_format,
        uri_format,
        iv_format,
        key_format_format,
        key_format_versions_format,
      ].compact
    end

    private def method_format
      "METHOD=#{method}"
    end

    private def uri_format
      %(URI="#{uri}") unless uri.nil?
    end

    private def iv_format
      "IV=#{iv}" unless iv.nil?
    end

    private def key_format_format
      %(KEYFORMAT="#{key_format}") unless key_format.nil?
    end

    private def key_format_versions_format
      %(KEYFORMATVERSIONS="#{key_format_versions}") unless key_format_versions.nil?
    end
  end
end
