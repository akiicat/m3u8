module M3U8
  # KeyItem represents a set of EXT-X-KEY attributes
  class KeyItem
    include Concern
    include Encryptable

    def to_s
      "#EXT-X-KEY:#{attributes_to_s}"
    end
  end
end
