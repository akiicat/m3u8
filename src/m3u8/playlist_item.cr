module M3U8
  # PlaylistItem represents a set of EXT-X-STREAM-INF or
  # EXT-X-I-FRAME-STREAM-INF attributes
  class PlaylistItem
    property program_id : Int32?
    property width : Int32?
    property height : Int32?
    property bandwidth : Int32?
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
    property codecs : Codecs

    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        program_id: params[:program_id]?,
        width: params[:width]?,
        height: params[:height]?,
        bandwidth: params[:bandwidth]?,
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
        codecs: params[:codecs]?,
        audio_codec: params[:audio_codec]?,
        level: params[:level]?,
        profile: params[:profile]?,
      )
    end

    def initialize(program_id = nil,
                   @width = nil,
                   @height = nil,
                   @bandwidth = nil,
                   @video = nil,
                   @audio = nil,
                   @uri = nil,
                   @average_bandwidth = nil,
                   @subtitles = nil,
                   @closed_captions = nil,
                   iframe = nil,
                   frame_rate = nil,
                   @name = nil,
                   @hdcp_level = nil,
                   codecs = nil,
                   audio_codec = nil,
                   level = nil,
                   profile = nil)

      @program_id = program_id ? program_id.to_i : nil
      @iframe = iframe ? true : false
      @frame_rate = frame_rate ? frame_rate.to_f : nil
      @codecs = Codecs.new({
        codecs: codecs,
        audio_codec: audio_codec,
        level: level,
        profile: profile,
      })
    end

    def resolution
      "#{width}x#{height}" unless width.nil?
    end

    def to_s
      if iframe
        %(#EXT-X-I-FRAME-STREAM-INF:#{attributes.join(',')},URI="#{uri}") 
      else
        %(#EXT-X-STREAM-INF:#{attributes.join(',')}\n#{uri})
      end
    end

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
      %(CODECS="#{codecs.to_s}") unless codecs.empty?
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
  end
end
