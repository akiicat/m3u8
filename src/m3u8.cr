require "big"
require "./patch/*"
require "./m3u8/concern" # preload
require "./m3u8/*"

module M3U8
  alias Items = SegmentItem | PlaylistItem | SessionDataItem | KeyItem | TimeItem | DiscontinuityItem | SessionKeyItem | PlaybackStart | MediaItem | MapItem | DateRangeItem
  alias ClientAttributeType = Hash(String | Symbol, String | Int32 | Float64 | Bool | Nil)

  include Protocol
end

# file = File.read("spec/playlists/playlist.m3u8")
file = File.read("spec/playlists/timestamp_playlist.m3u8")
M3U8::Parser.read file
file = File.read("spec/playlists/iframes.m3u8")
M3U8::Parser.read file
# scan = M3U8::Scanner.new file
# pp scan.current_line

