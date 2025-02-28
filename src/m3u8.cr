require "big"
require "./m3u8/concern"
require "./m3u8/*"

# This `M3U8` module provides functionality for working with m3u8 playlists in HTTP Live Streaming (HLS).
#
# In HLS, a `Playlist` can be one of two types:
#   - A Master Playlist, which defines a set of Variant Streams using tags.
#   - A Media Playlist, which lists individual media segments.
#
# The following tags and their corresponding classes or properties are supported:
#
# **Basic Tags:**
# - `EXTM3U`: Represents the start of a playlist (handled by the `Playlist` class).
# - `EXT-X-VERSION`: Indicates the protocol compatibility version (`Playlist#version`).
#
# **Media Playlist Tags:**
# - `EXT-X-TARGETDURATION`: The maximum segment duration (`Playlist#target`).
# - `EXT-X-MEDIA-SEQUENCE`: The sequence number of the first segment (`Playlist#sequence`).
# - `EXT-X-DISCONTINUITY-SEQUENCE`: The discontinuity sequence number (`Playlist#discontinuity_sequence`).
# - `EXT-X-ENDLIST`: Indicates that no more segments will be added (`Playlist.footer`).
# - `EXT-X-PLAYLIST-TYPE`: Specifies the playlist type (e.g., VOD or EVENT; `Playlist#type`).
# - `EXT-X-I-FRAMES-ONLY`: Marks an I-frame only playlist (`Playlist#iframes_only`).
# - `EXT-X-ALLOW-CACHE`: Indicates whether caching is allowed (`Playlist#cache`, deprecated in protocol version 7).
#
# **Media Segment Tags:**
# - `EXTINF`: Provides segment duration and an optional comment (`SegmentItem`).
# - `EXT-X-BYTERANGE`: Specifies a sub-range of a media segment (`ByteRange`).
# - `EXT-X-DISCONTINUITY`: Marks a discontinuity between segments (`DiscontinuityItem`).
# - `EXT-X-KEY`: Contains encryption key attributes (`KeyItem`).
# - `EXT-X-MAP`: Specifies the media initialization section (`MapItem`).
# - `EXT-X-PROGRAM-DATE-TIME`: Associates an absolute date and time with a segment (`TimeItem`).
# - `EXT-X-DATERANGE`: Associates a date range with a set of attributes (`DateRangeItem`).
#
# **Master Playlist Tags:**
# - `EXT-X-MEDIA`: Specifies alternative renditions (`MediaItem`).
# - `EXT-X-STREAM-INF`: Defines a Variant Stream (`PlaylistItem` with `PlaylistItem#iframe` set to false).
# - `EXT-X-I-FRAME-STREAM-INF`: Defines an I-frame only Variant Stream (`PlaylistItem` with `PlaylistItem#iframe` set to true).
# - `EXT-X-SESSION-DATA`: Contains session-level metadata (`SessionDataItem`).
# - `EXT-X-SESSION-KEY`: Contains session-level encryption key attributes (`SessionKeyItem`).
#
# **Common Tags (Applicable to both Media and Master Playlists):**
# - `EXT-X-INDEPENDENT-SEGMENTS`: Indicates that each segment can be decoded independently (`Playlist#independent_segments`).
# - `EXT-X-START`: Specifies the preferred start point for playback (`PlaybackStart`).
module M3U8
  private alias Items = SegmentItem | PlaylistItem | SessionDataItem | KeyItem | TimeItem | DiscontinuityItem | SessionKeyItem | PlaybackStart | MediaItem | MapItem | DateRangeItem
  private alias ClientAttributeType = Hash(String | Symbol, String | Int32 | Float64 | Bool | Nil)

  include Protocol
end
