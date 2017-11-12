module M3U8
  # KeyItem represents a set of EXT-X-KEY attributes
  class KeyItem
    include Encryptable
    extend M3U8

    def initialize(params)
      options = convert_key_names(params)

      @method = options[:method]
      @uri = options[:uri]
      @iv = options[:iv]
      @key_format = options[:key_format]
      @key_format_versions = options[:key_format_versions]
    end

    # def self.parse(text)
    #   attributes = parse_attributes(text)
    #   KeyItem.new(attributes)
    # end

    def to_s
      "#EXT-X-KEY:#{attributes_to_s}"
    end
  end
end
