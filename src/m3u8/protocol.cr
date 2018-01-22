module M3U8
  module Protocol
    def self.parse(tag : String)
      Mapping[tag]?
    end

    Mapping = {
      # Basic Tags
      "#EXTM3U": :extm3u,
      "#EXT-X-VERSION": :ext_x_version,

      # media segment tags
      "#EXTINF": :extinf,
      "#EXT-X-BYTERANGE": :ext_x_byterange,
      "#EXT-X-DISCONTINUITY": :ext_x_discontinuity,
      "#EXT-X-KEY": :ext_x_key,
      "#EXT-X-MAP": :ext_x_map,
      "#EXT-X-PROGRAM-DATE-TIME": :ext_x_program_date_time,
      "#EXT-X-DATERANGE": :ext_x_daterange,

      # Media Playlist Tags
      "#EXT-X-TARGETDURATION": :ext_x_targetduration,
      "#EXT-X-MEDIA-SEQUENCE": :ext_x_media_sequence,
      "#EXT-X-DISCONTINUITY-SEQUENCE": :ext_x_discontinuity_sequence,
      "#EXT-X-ENDLIST": :ext_x_endlist,
      "#EXT-X-PLAYLIST-TYPE": :ext_x_playlist_type,
      "#EXT-X-I-FRAMES-ONLY": :ext_x_i_frames_only,
      "#EXT-X-ALLOW-CACHE": :ext_x_allow_cache,

      # Master Playlist Tags
      "#EXT-X-MEDIA": :ext_x_media,
      "#EXT-X-STREAM-INF": :ext_x_stream_inf,
      "#EXT-X-I-FRAME-STREAM-INF": :ext_x_i_frame_stream_inf,
      "#EXT-X-SESSION-DATA": :ext_x_session_data,
      "#EXT-X-SESSION-KEY": :ext_x_session_key,

      # Media or Master Playlist Tags
      "#EXT-X-INDEPENDENT-SEGMENTS": :ext_x_independent_segments,
      "#EXT-X-START": :ext_x_start,

      # Experimental Tags
      "#EXT-X-CUE-OUT": :ext_x_cue_out,
      "#EXT-X-CUE-OUT-CONT": :ext_x_cue_out_cont,
      "#EXT-X-CUE-IN": :ext_x_cue_in,
      "#EXT-X-CUE-SPAN": :ext_x_cue_span,
      "#EXT-OATCLS-SCTE35": :ext_oatcls_scte35,
    }


    BASIC_TAGS = [
      :extm3u,
      :ext_x_version,
    ]

    MEDIA_SEGMENT_TAGS = [
      :extinf,
      :ext_x_byterange,
      :ext_x_discontinuity,
      :ext_x_key,
      :ext_x_map,
      :ext_x_program_date_time,
      :ext_x_daterange,
    ]

    MEDIA_PLAYLIST_TAGS = [
      :ext_x_targetduration,
      :ext_x_media_sequence,
      :ext_x_discontinuity_sequence,
      :ext_x_endlist,
      :ext_x_playlist_type,
      :ext_x_i_frames_only,
      :ext_x_allow_cache,
    ]

    MASTER_PLAYLIST_TAGS = [
      :ext_x_media,
      :ext_x_stream_inf,
      :ext_x_i_frame_stream_inf,
      :ext_x_session_data,
      :ext_x_session_key,
    ]

    MASTER_MEDIA_PLAYLIST_TAGS = [
      :ext_x_independent_segments,
      :ext_x_start,
    ]

    EXPERIMENTAL_TAGS = [
      :ext_x_cue_out,
      :ext_x_cue_out_cont,
      :ext_x_cue_in,
      :ext_x_cue_span,
      :ext_oatcls_scte35,
    ]

    MEDIA_TAGS = [
      MEDIA_SEGMENT_TAGS,
      MEDIA_PLAYLIST_TAGS
    ].flatten

    ALL_TAGS = [
      BASIC_TAGS,
      MEDIA_SEGMENT_TAGS,
      MEDIA_PLAYLIST_TAGS,
      MASTER_PLAYLIST_TAGS,
      MASTER_MEDIA_PLAYLIST_TAGS,
      EXPERIMENTAL_TAGS,
    ].flatten
  end
end

