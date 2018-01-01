require "json"

module M3U8
  # DateRangeItem represents a #EXT-X-DATERANGE tag
  class DateRangeItem
    private alias ClientAttributeType = Hash(String | Symbol, String | Int32 | Float64 | Bool | Nil)

    property id : String
    property start_date : String
    property class_name : String?
    property end_date : String?
    property duration : Float64?
    property planned_duration : Float64?
    property scte35_cmd : String?
    property scte35_out : String?
    property scte35_in : String?
    property end_on_next : Bool?
    property client_attributes : ClientAttributeType

    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        id: params[:id],
        start_date: params[:start_date],
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

    # def parse(text)
    #   array = text.delete("\n").scan(/([A-z0-9-]+)\s*=\s*("[^"]*"|[^,]*)/)
    #   array.each do |arr|
    #     key, value = arr[1], arr[2]

    #     case value
    #     # float
    #     when /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/
    #       write_attr(key, value.to_f)
    #     # int
    #     when /^([+-]?[0-9]\d*|0)$/
    #       write_attr(key, value.to_i)
    #     # bool
    #     when "true", "false"
    #       write_attr(key, value.to_boolean)
    #     else
    #       write_attr(key, value.delete('"'))
    #     end
    #   end
    # end

    # def write_attr(key, value)
    #   case value
    #   when String
    #     case key
    #     when :id, "ID"
    #       @id = value
    #     when :class_name, "CLASS"
    #       @class_name = value
    #     when :start_date, "START-DATE"
    #       @start_date = value
    #     when :end_date, "END-DATE"
    #       @end_date = value
    #     when :duration, "DURATION"
    #       @duration = value.to_f
    #     when :planned_duration, "PLANNED-DURATION"
    #       @planned_duration = value.to_f
    #     when :scte35_cmd, "SCTE35-CMD"
    #       @scte35_cmd = value
    #     when :scte35_out, "SCTE35-OUT"
    #       @scte35_out = value
    #     when :scte35_in, "SCTE35-IN"
    #       @scte35_in = value
    #     when :end_on_next, "END-ON-NEXT"
    #       @end_on_next = value.to_boolean
    #     when /^X-/
    #       @client_attributes[key] = value
    #     end

    #   when Float64
    #     case key
    #     when :duration, "DURATION"
    #       @duration = value
    #     when :planned_duration, "PLANNED-DURATION"
    #       @planned_duration = value
    #     when /^X-/
    #       @client_attributes[key] = value
    #     end

    #   when Bool
    #     case key
    #     when :end_on_next, "END-ON-NEXT"
    #       @end_on_next = value
    #     when /^X-/
    #       @client_attributes[key] = value
    #     end

    #   when Hash
    #     case key
    #     when :client_attributes
    #       parse_client_attributes(value).each do |k, v|
    #         write_attr(k, v)
    #       end
    #     end

    #   end
    # end

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

    private def parse_client_attributes(attributes)
      hash = ClientAttributeType.new
      if attributes
        hash.merge!(attributes.select { |key| key.starts_with?("X-") })
      end
      hash
    end
  end
end
