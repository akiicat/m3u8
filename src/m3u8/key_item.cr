module M3U8
  # KeyItem represents a set of EXT-X-KEY attributes
  class KeyItem

    include Encryptable

    # def self.parse(text)
    #   attributes = parse_attributes(text)
    #   KeyItem.new(attributes)
    # end

    def to_s
      "#EXT-X-KEY:#{attributes_to_s}"
    end
  end
end
