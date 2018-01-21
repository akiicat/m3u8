require "json"

module M3U8
  # DateRangeItem represents a #EXT-X-DATERANGE tag
  class DateRangeItem
    include Concern

    property id : String?
    property start_date : String?
    property class_name : String?
    property end_date : String?
    property duration : Float64?
    property planned_duration : Float64?
    property scte35_cmd : String?
    property scte35_out : String?
    property scte35_in : String?
    property end_on_next : Bool?
    property client_attributes : ClientAttributeType

    def self.parse(text)
      params = parse_attributes(text)
      new(
        id: params["ID"]?,
        class_name: params["CLASS"]?,
        start_date: params["START-DATE"]?,
        end_date: params["END-DATE"]?,
        duration: params["DURATION"]?.try &.to_f,
        planned_duration: params["PLANNED-DURATION"]?.try &.to_f,
        scte35_cmd: params["SCTE35-CMD"]?,
        scte35_out: params["SCTE35-OUT"]?,
        scte35_in: params["SCTE35-IN"]?,
        end_on_next: params["END-ON-NEXT"]?.try &.to_boolean,
        client_attributes: parse_client_attributes(params),
      )
    end

    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        id: params[:id]?,
        start_date: params[:start_date]?,
        class_name: params[:class_name]?,
        end_date: params[:end_date]?,
        duration: params[:duration]?,
        planned_duration: params[:planned_duration]?,
        scte35_cmd: params[:scte35_cmd]?,
        scte35_out: params[:scte35_out]?,
        scte35_in: params[:scte35_in]?,
        end_on_next: params[:end_on_next]?,
        client_attributes: params[:client_attributes]?,
      )
    end

    def initialize(@id, @start_date, @class_name = nil, @end_date = nil, @duration = nil, @planned_duration = nil,
                   @scte35_cmd = nil, @scte35_out = nil, @scte35_in = nil, @end_on_next = nil, client_attributes = nil)
      @client_attributes = parse_client_attributes(client_attributes)
    end

    def to_s
      "#EXT-X-DATERANGE:#{attributes.join(',')}"
    end

    def attributes
      [
        id_format,
        class_name_format,
        start_date_format,
        end_date_format,
        duration_format,
        planned_duration_format,
        client_attributes_format,
        scte35_cmd_format,
        scte35_out_format,
        scte35_in_format,
        end_on_next_format
      ].compact
    end

    private def id_format
      %(ID="#{id}")
    end

    private def class_name_format
      %(CLASS="#{class_name}") unless class_name.nil?
    end

    private def start_date_format
      %(START-DATE="#{start_date}")
    end

    private def end_date_format
      %(END-DATE="#{end_date}") unless end_date.nil?
    end

    private def duration_format
      "DURATION=#{duration}" unless duration.nil?
    end

    private def planned_duration_format
      "PLANNED-DURATION=#{planned_duration}" unless planned_duration.nil?
    end

    private def scte35_cmd_format
      "SCTE35-CMD=#{scte35_cmd}" unless scte35_cmd.nil?
    end

    private def scte35_out_format
      "SCTE35-OUT=#{scte35_out}" unless scte35_out.nil?
    end

    private def scte35_in_format
      "SCTE35-IN=#{scte35_in}" unless scte35_in.nil?
    end

    private def end_on_next_format
      "END-ON-NEXT=YES" if end_on_next
    end

    private def client_attributes_format
      return if client_attributes.empty?
      client_attributes.map do |attribute|
        value = attribute.last
        value_format = value.is_a?(String) ? %("#{value}") : value
        "#{attribute.first}=#{value_format}"
      end.join(',')
    end
  end
end
