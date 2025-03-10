# m3u8

[![Build Status](https://github.com/akiicat/m3u8/actions/workflows/crystal.yml/badge.svg)](https://github.com/akiicat/m3u8/actions)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://akiicat.github.io/m3u8)
[![GitHub release](https://img.shields.io/github/release/akiicat/m3u8.svg)](https://github.com/akiicat/m3u8/releases)

Generate and parse m3u8 playlists for HTTP Live Streaming (HLS).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  m3u8:
    github: akiicat/m3u8
```

## Usage

```crystal
require "m3u8"

module App
  include M3U8
end
```

[Document](https://akiicat.github.io/m3u8/)

### Generate

```crystal
playlist = Playlist.new
playlist.items << SegmentItem.new(duration: 10.991, segment: "test_01.ts")
playlist.to_s
```

```
#EXTM3U
#EXT-X-MEDIA-SEQUENCE:0
#EXT-X-TARGETDURATION:10
#EXTINF:10.991,
test_01.ts
#EXT-X-ENDLIST
```

### Parse

```crystal
file = File.read "spec/playlists/master.m3u8"
playlist = Playlist.parse(file)
playlist.master? # => true
```

## Development

### Supported Playlist Tags

#### Basic Tags
- [x] EXTM3U
- [x] EXT-X-VERSION

#### media segment tags
- [x] EXTINF
- [x] EXT-X-BYTERANGE
- [x] EXT-X-DISCONTINUITY
- [x] EXT-X-KEY
- [x] EXT-X-MAP
- [x] EXT-X-PROGRAM-DATE-TIME
- [x] EXT-X-DATERANGE

#### Media Playlist Tags
- [x] EXT-X-TARGETDURATION
- [x] EXT-X-MEDIA-SEQUENCE
- [x] EXT-X-DISCONTINUITY-SEQUENCE
- [x] EXT-X-ENDLIST
- [x] EXT-X-PLAYLIST-TYPE
- [x] EXT-X-I-FRAMES-ONLY
- [x] EXT-X-ALLOW-CACHE (was removed in protocol version 7)

#### Master Playlist Tags
- [x] EXT-X-MEDIA
- [x] EXT-X-STREAM-INF
- [x] EXT-X-I-FRAME-STREAM-INF
- [x] EXT-X-SESSION-DATA
- [x] EXT-X-SESSION-KEY

#### Media or Master Playlist Tags
- [x] EXT-X-INDEPENDENT-SEGMENTS
- [x] EXT-X-START

#### Experimental Tags
- [ ] EXT-X-CUE-OUT
- [ ] EXT-X-CUE-OUT-CONT
- [ ] EXT-X-CUE-IN
- [ ] EXT-X-CUE-SPAN
- [ ] EXT-OATCLS-SCTE35

## Contributing

1. Fork it ( https://github.com/akiicat/m3u8/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Akiicat](https://github.com/akiicat) Akiicat - creator, maintainer
