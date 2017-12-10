module M3U8
  # Encapsulates logic common to encryption key tags
  module Encryptable
    property method : String = ""
    property uri : String | Nil = nil
    property iv : String | Nil = nil
    property key_format : String | Nil = nil
    property key_format_versions : String | Nil = nil

    def attributes_to_s
      [
        method_format,
        uri_format,
        iv_format,
        key_format_format,
        key_format_versions_format,
      ].compact.join(',')
    end

    def write_attributes(params)
      @method = params[:method]
      @uri = params[:uri]?
      @iv = params[:iv]?
      @key_format = params[:key_format]?
      @key_format_versions = params[:key_format_versions]?
    end

    def convert_key_names(attributes)
      {
        method:              attributes[:method],
        uri:                 attributes[:uri]?,
        iv:                  attributes[:iv]?,
        key_format:          attributes[:key_format]?,
        key_format_versions: attributes[:key_format_versions]?,
      }
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
