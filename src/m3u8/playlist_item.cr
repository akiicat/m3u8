module M3U8
  # PlaylistItem represents a set of EXT-X-STREAM-INF or
  # EXT-X-I-FRAME-STREAM-INF attributes
  class PlaylistItem
    property program_id : Int32?
    property width : Int32?
    property height : Int32?
    property codecs : String?
    property bandwidth : Int32?
    property audio_codec : String?
    property level : Float64?
    property profile : String?
    property video : String?
    property audio : String?
    property uri : String?
    property average_bandwidth : Int32?
    property subtitles : String?
    property closed_captions : String?
    property iframe : Bool
    property frame_rate : Float64?
    property name : String?
    property hdcp_level : String?

    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        program_id: params[:program_id]?,
        width: params[:width]?,
        height: params[:height]?,
        codecs: params[:codecs]?,
        bandwidth: params[:bandwidth]?,
        audio_codec: params[:audio_codec]?,
        level: params[:level]?,
        profile: params[:profile]?,
        video: params[:video]?,
        audio: params[:audio]?,
        uri: params[:uri]?,
        average_bandwidth: params[:average_bandwidth]?,
        subtitles: params[:subtitles]?,
        closed_captions: params[:closed_captions]?,
        iframe: params[:iframe]?,
        frame_rate: params[:frame_rate]?,
        name: params[:name]?,
        hdcp_level: params[:hdcp_level]?,
      )
    end

    def initialize(program_id = nil,
                   @width = nil,
                   @height = nil,
                   @codecs = nil,
                   @bandwidth = nil,
                   @audio_codec = nil,
                   level = nil,
                   @profile = nil,
                   @video = nil,
                   @audio = nil,
                   @uri = nil,
                   @average_bandwidth = nil,
                   @subtitles = nil,
                   @closed_captions = nil,
                   iframe = nil,
                   frame_rate = nil,
                   @name = nil,
                   @hdcp_level = nil)

      @program_id = program_id ? program_id.to_i : nil
      @level = level ? level.to_f : nil
      @iframe = iframe ? true : false
      @frame_rate = frame_rate ? frame_rate.to_f : nil
    end

    # def self.parse(text)
    #   item = PlaylistItem.new
    #   item.parse(text)
    #   item
    # end

    # def parse(text)
    #   attributes = parse_attributes(text)
    #   options = options_from_attributes(attributes)
    #   initialize(options)
    # end

    def resolution
      "#{width}x#{height}" unless width.nil?
    end

    def codecs
      return @codecs unless @codecs.nil?

      video_codec_string = video_codec(profile, level)

      # profile and/or level were specified but not recognized,
      # do not specify any codecs
      return nil if !(profile.nil? && level.nil?) && video_codec_string.nil?

      audio_codec_string = audio_codec_code

      # audio codec was specified but not recognized,
      # do not specify any codecs
      return nil if !audio_codec.nil? && audio_codec_string.nil?

      codec_strings = [video_codec_string, audio_codec_string].compact
      codec_strings.empty? ? nil : codec_strings.join(',')
    end

    def to_s
      if iframe
        %(#EXT-X-I-FRAME-STREAM-INF:#{attributes.join(',')},URI="#{uri}") 
      else
        %(#EXT-X-STREAM-INF:#{attributes.join(',')}\n#{uri})
      end
    end

    # private

    # def options_from_attributes(attributes)
    #   resolution = parse_resolution(attributes["RESOLUTION"])
    #   { program_id: attributes["PROGRAM-ID"],
    #     codecs: attributes["CODECS"],
    #     width: resolution[:width],
    #     height: resolution[:height],
    #     bandwidth: attributes["BANDWIDTH"].to_i,
    #     average_bandwidth:
    #       parse_average_bandwidth(attributes["AVERAGE-BANDWIDTH"]),
    #     frame_rate: parse_frame_rate(attributes["FRAME-RATE"]),
    #     video: attributes["VIDEO"], audio: attributes["AUDIO"],
    #     uri: attributes["URI"], subtitles: attributes["SUBTITLES"],
    #     closed_captions: attributes["CLOSED-CAPTIONS"],
    #     name: attributes["NAME"], hdcp_level: attributes["HDCP-LEVEL"] }
    # end

    # def parse_average_bandwidth(value)
    #   value.to_i unless value.nil?
    # end

    # def parse_resolution(resolution)
    #   return { width: nil, height: nil } if resolution.nil?

    #   values = resolution.split('x')
    #   width = values[0].to_i
    #   height = values[1].to_i
    #   { width: width, height: height }
    # end

    # def parse_frame_rate(frame_rate)
    #   return if frame_rate.nil?

    #   value = BigDecimal(frame_rate)
    #   value if value > 0
    # end

    private def attributes
      [
        program_id_format,
        resolution_format,
        codecs_format,
        bandwidth_format,
        average_bandwidth_format,
        frame_rate_format,
        hdcp_level_format,
        audio_format,
        video_format,
        subtitles_format,
        closed_captions_format,
        name_format
      ].compact
    end

    private def program_id_format
      %(PROGRAM-ID=#{program_id}) unless program_id.nil?
    end

    private def resolution_format
      %(RESOLUTION=#{resolution}) unless resolution.nil?
    end

    private def frame_rate_format
      %(FRAME-RATE=%.3f) % frame_rate unless frame_rate.nil?
    end

    private def hdcp_level_format
      %(HDCP-LEVEL=#{hdcp_level}) unless hdcp_level.nil?
    end

    private def codecs_format
      %(CODECS="#{codecs}") unless codecs.nil?
    end

    private def bandwidth_format
      %(BANDWIDTH=#{bandwidth}) unless bandwidth.nil?
    end

    private def average_bandwidth_format
      %(AVERAGE-BANDWIDTH=#{average_bandwidth}) unless average_bandwidth.nil?
    end

    private def audio_format
      %(AUDIO="#{audio}") unless audio.nil?
    end

    private def video_format
      %(VIDEO="#{video}") unless video.nil?
    end

    private def subtitles_format
      %(SUBTITLES="#{subtitles}") unless subtitles.nil?
    end

    private def closed_captions_format
      case closed_captions
      when "NONE" then %(CLOSED-CAPTIONS=NONE)
      when String then %(CLOSED-CAPTIONS="#{closed_captions}")
      end
    end

    private def name_format
      %(NAME="#{name}") unless name.nil?
    end

    private def audio_codec_code
      case audio_codec.to_s.downcase
      when "aac-lc" then "mp4a.40.2" 
      when "he-aac" then "mp4a.40.5"
      when "mp3" then "mp4a.40.34"
      end
    end

    private def video_codec(profile, level)
      return if profile.nil? || level.nil?

      case profile
      when "baseline" then baseline_codec_string(level)
      when "main" then main_codec_string(level)
      when "high" then high_codec_string(level)
      end
    end

    private def baseline_codec_string(level)
      case level
      when 3.0 then "avc1.66.30"
      when 3.1 then "avc1.42001f"
      end
    end

    private def main_codec_string(level)
      case level
      when 3.0 then "avc1.77.30"
      when 3.1 then "avc1.4d001f"
      when 4.0 then "avc1.4d0028"
      when 4.1 then "avc1.4d0029"
      end
    end

    private def high_codec_string(level)
      case level
      when 3.1 then "avc1.64001f"
      when 4.0 then "avc1.640028"
      when 4.1 then "avc1.640029"
      end
    end
  end
end
