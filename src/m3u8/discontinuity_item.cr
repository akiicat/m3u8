module M3U8
  # `DiscontinuityItem` represents an `EXT-X-DISCONTINUITY` tag used in HLS playlists.
  #
  # According to [RFC 8216, Section 4.3.2.4](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.2.4),
  # the `EXT-X-DISCONTINUITY` tag signals that a discontinuity exists between Media Segment items.
  # This break in continuity can occur due to changes in encoding parameters, stream content,
  # or other reasons that require the client to reset its decoding process.
  #
  # For example, an HLS playlist might include the following tag to indicate a discontinuity:
  #
  # ```txt
  # #EXT-X-DISCONTINUITY
  # ```
  #
  # When the client parses this tag, it understands that the next Media Segment should be treated
  # as starting from a new point, independent of the segments that came before.
  class DiscontinuityItem
    include Concern

    # Returns the `EXT-X-DISCONTINUITY` tag as a string, followed by a newline.
    #
    # Example:
    #
    # ```
    # DiscontinuityItem.new.to_s
    # # => "#EXT-X-DISCONTINUITY\n"
    # ```
    #
    # The newline character ensures that when concatenated in a Playlist,
    # the tag is correctly terminated as a separate line.
    def to_s
      %(#EXT-X-DISCONTINUITY\n)
    end
  end
end
