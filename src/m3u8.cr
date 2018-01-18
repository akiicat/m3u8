require "./patch/*"
require "./m3u8/*"

module M3U8
  alias Items = SegmentItem | PlaylistItem | SessionDataItem | KeyItem | TimeItem | DiscontinuityItem | SessionKeyItem

  include Protocol
end
