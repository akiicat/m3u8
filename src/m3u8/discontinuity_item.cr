module M3U8
  # DiscontinuityItem represents a EXT-X-DISCONTINUITY tag to indicate a
  # discontinuity between the SegmentItems that proceed and follow it.
  class DiscontinuityItem
    include Concern

    # ```
    # DiscontinuityItem.new.to_s
    # # => "#EXT-X-DISCONTINUITY\n"
    # ```
    def to_s
      %(#EXT-X-DISCONTINUITY\n)
    end
  end
end
