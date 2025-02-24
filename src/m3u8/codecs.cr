module M3U8
  # `Codecs` represents the *CODECS* attribute used in HTTP Live Streaming (HLS).
  #
  # In HLS ([RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216)), the *CODECS* attribute (further detailed in [RFC 6381](https://datatracker.ietf.org/doc/html/rfc6381))
  # is a comma-separated list of codec identifiers that describe the media
  # contained in a Media Segment. This attribute is used in the `EXT-X-STREAM-INF`
  # tag to indicate what codecs (and profiles) are required to play back a stream.
  #
  # ```txt
  # #EXT-X-STREAM-INF:BANDWIDTH=65000,CODECS="mp4a.40.5"
  # audio-only.m3u8
  # ```
  #
  # There are two primary ways to use `Codecs`:
  #
  # 1. If the `codecs` property is set, that pre-computed string is used directly.
  #
  # 2. Otherwise, the `codecs` string is constructed by deriving the video and audio
  #    codec codes from the remaining properties:
  #
  #    - For audio, the `audio_codec` property is mapped as follows:
  #
  # ```txt
  #         "aac-lc"  => "mp4a.40.2"  (AAC low complexity)
  #         "he-aac"  => "mp4a.40.5"  (HE-AAC)
  #         "mp3"     => "mp4a.40.34" (MPEG-1 Audio Layer 3)
  # ```
  #
  #    - For video, both the `profile` and `level` properties must be provided.
  #      For example, for H.264 (AVC) video the following mappings are used:
  #
  # ```txt
  #         Baseline Profile:
  #           Level 3.0 => "avc1.66.30"
  #           Level 3.1 => "avc1.42001f"
  #
  #         Main Profile:
  #           Level 3.0 => "avc1.77.30"
  #           Level 3.1 => "avc1.4d001f"
  #           Level 4.0 => "avc1.4d0028"
  #           Level 4.1 => "avc1.4d0029"
  #
  #         High Profile:
  #           Level 3.1 => "avc1.64001f"
  #           Level 4.0 => "avc1.640028"
  #           Level 4.1 => "avc1.640029"
  # ```
  #
  # When constructing the codec string:
  # - If a video codec is expected (i.e. both `profile` and `level` are provided) but the
  #   mapping is not recognized, no codec string is output.
  # - Likewise, if an `audio_codec` is specified but unrecognized, the codec string is empty.
  #
  # For more details on these mappings and the overall semantics of HLS, refer to:
  #   - [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216) (HTTP Live Streaming) [Section 4.3.4.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.4.2)
  #   - [RFC 6381](https://datatracker.ietf.org/doc/html/rfc6381) (The 'Codecs' and 'Profiles' Parameters for "Bucket" Media Types)
  #   - [The HTTP Live Streaming FAQ](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/StreamingMediaGuide/FrequentlyAskedQuestions/FrequentlyAskedQuestions.html) (which discusses recommended values for stream playback)
  class Codecs
    include Concern

    # Predefined codec string
    property codecs : String?

    # Audio codec identifier (e.g., `aac-lc`)
    property audio_codec : String?

    # Video level (e.g., `3.0`, `3.1`, etc.)
    #
    # The video `codecs` string is determined from both the video `profile` and `level`.
    #
    # - `baseline` Profile:
    #   - Level `3.0` => `avc1.66.30`
    #   - Level `3.1` => `avc1.42001f`
    #
    # - `main` Profile:
    #   - Level `3.0` => `avc1.77.30`
    #   - Level `3.1` => `avc1.4d001f`
    #   - Level `4.0` => `avc1.4d0028`
    #   - Level `4.1` => `avc1.4d0029`
    #
    # - `high` Profile:
    #   - Level `3.1` => `avc1.64001f`
    #   - Level `4.0` => `avc1.640028`
    #   - Level `4.1` => `avc1.640029`
    property level : Float64?

    # Video profile (e.g., `baseline`, `main`, `high`)
    #
    # The video `codecs` string is determined from both the video `profile` and `level`.
    #
    # - `baseline` Profile:
    #   - Level `3.0` => `avc1.66.30`
    #   - Level `3.1` => `avc1.42001f`
    #
    # - `main` Profile:
    #   - Level `3.0` => `avc1.77.30`
    #   - Level `3.1` => `avc1.4d001f`
    #   - Level `4.0` => `avc1.4d0028`
    #   - Level `4.1` => `avc1.4d0029`
    #
    # - `high` Profile:
    #   - Level `3.1` => `avc1.64001f`
    #   - Level `4.0` => `avc1.640028`
    #   - Level `4.1` => `avc1.640029`
    property profile : String?

    # Creates a new `Codecs` instance from a NamedTuple.
    #
    # Examples:
    #
    # ```crystal
    # options = { audio_codec: "aac-lc" }
    # Codecs.new(options)
    # Codecs.new(audio_codec: "aac-lc")
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        codecs: params[:codecs]?,
        audio_codec: params[:audio_codec]?,
        level: params[:level]?,
        profile: params[:profile]?,
      )
    end

    # Initializes a new `Codecs` instance.
    # Parameters with `@` prefix are automatically assigned as instance variables.
    #
    # Parameters:
    # - `codecs`: A pre-computed codec string (if provided, it is used directly).
    # - `audio_codec`: The name of the audio codec (e.g. `aac-lc`, `he-aac`, `mp3`).
    # - `level`: The numeric level used to determine the video codec.
    # - `profile`: The video profile (e.g. `baseline`, `main`, `high`).
    #
    # Example:
    #
    # ```crystal
    # Codecs.new
    # ```
    def initialize(@codecs = nil,
                   @audio_codec = nil,
                   level = nil,
                   @profile = nil)
      @level = level.try &.to_f
    end

    # Returns the *CODECS* string for this instance.
    #
    # If a pre-computed `codecs` string is provided, it is returned directly.
    # Otherwise, the method constructs the `codecs` string by computing the video codec
    # (from `profile` and `level`) and the audio codec (from `audio_codec`).
    #
    # Examples:
    #
    # ```crystal
    # Codecs.new(codecs: "test").to_s                                      # => "test"
    # Codecs.new(audio_codec: "aac-lc").to_s                               # => "mp4a.40.2"
    # Codecs.new(profile: "baseline", level: 3.0, audio_codec: "mp3").to_s # => "avc1.66.30,mp4a.40.34"
    # ```
    def to_s
      return codecs || "" if codecs

      video_codec_string = video_codec_code

      # If both profile and level are provided but no valid video codec is mapped,
      # then we output an empty string.
      return "" if profile && level && video_codec_string.nil?

      audio_codec_string = audio_codec_code

      # If an audio codec was specified but not recognized, do not output any codecs.
      return "" if audio_codec && audio_codec_string.nil?

      # Join the video and audio codec strings (ignoring nil values) with a comma.
      [video_codec_string, audio_codec_string].compact.join(',')
    end

    # Returns true if the `codecs` string is empty.
    #
    # Examples:
    #
    # ```
    # codecs = Codecs.new
    # codecs.empty? # => true
    # codecs.audio_codec = "aac-lc"
    # codecs.empty? # => false
    # ```
    def empty?
      to_s.empty?
    end

    # Compares this `Codecs` instance with another `Codecs` instance.
    #
    # Equality is determined by comparing their *CODECS* strings.
    #
    # Example:
    #
    # ```crystal
    # left = Codecs.new(audio_codec: "aac-lc")
    # right = Codecs.new(audio_codec: "aac-lc")
    # left == right  # => true
    # ```
    def ==(other : Codecs)
      to_s == other.to_s
    end

    # Compares this `Codecs` instance with a String.
    #
    # The instance is considered equal to the string if its *CODECS* string matches.
    #
    # Example:
    #
    # ```crystal
    # left = Codecs.new(audio_codec: "aac-lc")
    # right = "aac-lc"
    # left == right  # => true
    # ```
    def ==(other : String)
      to_s == other
    end

    private def audio_codec_code
      return if audio_codec.nil?

      case audio_codec.not_nil!.downcase
      when "aac-lc" then "mp4a.40.2"
      when "he-aac" then "mp4a.40.5"
      when "mp3"    then "mp4a.40.34"
      end
    end

    private def video_codec_code
      return if profile.nil? || level.nil?

      case profile
      when "baseline" then baseline_codec_string
      when "main"     then main_codec_string
      when "high"     then high_codec_string
      end
    end

    private def baseline_codec_string
      case level
      when 3.0 then "avc1.66.30"
      when 3.1 then "avc1.42001f"
      end
    end

    private def main_codec_string
      case level
      when 3.0 then "avc1.77.30"
      when 3.1 then "avc1.4d001f"
      when 4.0 then "avc1.4d0028"
      when 4.1 then "avc1.4d0029"
      end
    end

    private def high_codec_string
      case level
      when 3.1 then "avc1.64001f"
      when 4.0 then "avc1.640028"
      when 4.1 then "avc1.640029"
      end
    end
  end
end
