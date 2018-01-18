module M3U8
  # KeyItem represents a set of EXT-X-SESSION-KEY attributes
  # https://tools.ietf.org/html/draft-pantos-http-live-streaming-20#page-33
  class SessionKeyItem

    include Encryptable

    def to_s
      "#EXT-X-SESSION-KEY:#{attributes_to_s}"
    end
  end
end
