module M3U8
  class Codecs
    include Concern

    property codecs : String?
    property audio_codec : String?
    property level : Float64?
    property profile : String?

    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        codecs: params[:codecs]?,
        audio_codec: params[:audio_codec]?,
        level: params[:level]?,
        profile: params[:profile]?,
      )
    end

    def initialize(@codecs = nil,
                   @audio_codec = nil,
                   level = nil,
                   @profile = nil)

      @level = level ? level.to_f : nil
    end

    def to_s
      return codecs.empty? ? "" : codecs if codecs

      video_codec_string = video_codec_code

      # profile and/or level were specified but not recognized,
      # do not specify any codecs
      return if profile && level && video_codec_string.nil?

      audio_codec_string = audio_codec_code

      # audio codec was specified but not recognized,
      # do not specify any codecs
      return if audio_codec && audio_codec_string.nil?

      codec_strings = [video_codec_string, audio_codec_string].compact
      codec_strings.empty? ? "" : codec_strings.join(',')
    end

    def empty?
      to_s.empty?
    end

    def ==(other : Codecs)
      to_s == other.to_s
    end

    def ==(other : String)
      to_s == other
    end

    def ==(other : Nil)
      empty?
    end

    private def audio_codec_code
      return if audio_codec.nil?

      case audio_codec.not_nil!.downcase
      when "aac-lc" then "mp4a.40.2" 
      when "he-aac" then "mp4a.40.5"
      when "mp3" then "mp4a.40.34"
      end
    end

    private def video_codec_code
      return if profile.nil? || level.nil?

      case profile
      when "baseline" then baseline_codec_string
      when "main" then main_codec_string
      when "high" then high_codec_string
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
