# m3u8

TODO: Write a description here

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
```

TODO: Write usage instructions here

## Development

- [x] byte_range
- [x] date_range_item
- [x] discontinuity_item
- [x] encryptable
- [x] error
- [x] key_item
- [x] map_item
- [x] media_item
- [x] playback_start
- [x] playlist
- [x] playlist_item
- [ ] reader
- [x] segment_item
- [x] session_data_item
- [x] session_key_item
- [x] time_item
- [x] version
- [x] ~writer~
- [x] codecs
- [x] concern

## Supported Playlist Tags

### Basic Tags
- [x] EXTM3U
- [x] EXT-X-VERSION

### media segment tags
- [x] EXTINF
- [x] EXT-X-BYTERANGE
- [x] EXT-X-DISCONTINUITY
- [x] EXT-X-KEY
- [x] EXT-X-MAP
- [x] EXT-X-PROGRAM-DATE-TIME
- [x] EXT-X-DATERANGE

### Media Playlist Tags
- [x] EXT-X-TARGETDURATION
- [x] EXT-X-MEDIA-SEQUENCE
- [x] EXT-X-DISCONTINUITY-SEQUENCE
- [x] EXT-X-ENDLIST
- [x] EXT-X-PLAYLIST-TYPE
- [x] EXT-X-I-FRAMES-ONLY
- [x] EXT-X-ALLOW-CACHE (was removed in protocol version 7)

### Master Playlist Tags
- [x] EXT-X-MEDIA
- [x] EXT-X-STREAM-INF
- [x] EXT-X-I-FRAME-STREAM-INF
- [x] EXT-X-SESSION-DATA
- [x] EXT-X-SESSION-KEY

### Media or Master Playlist Tags
- [x] EXT-X-INDEPENDENT-SEGMENTS
- [x] EXT-X-START

### Experimental Tags

- [ ] #EXT-X-CUE-OUT
- [ ] #EXT-X-CUE-OUT-CONT
- [ ] #EXT-X-CUE-IN
- [ ] #EXT-X-CUE-SPAN
- [ ] #EXT-OATCLS-SCTE35

## Contributing

1. Fork it ( https://github.com/akiicat/m3u8/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Akiicat](https://github.com/akiicat) Akiicat - creator, maintainer
