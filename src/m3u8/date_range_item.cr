require "json"

module M3U8
  # DateRangeItem represents a #EXT-X-DATERANGE tag
  class DateRangeItem
    include M3U8

    # alias DateTangeType = NamedTuple
    private alias ClientAttributeType = Hash(String | Symbol, String | Int32 | Float64 | Bool)

    property id : String?
    property class_name : String?
    property start_date : String?
    property end_date : String?
    property duration : Float64?
    property planned_duration : Float64?
    property scte35_cmd : String?
    property scte35_out : String?
    property scte35_in : String?
    property end_on_next : Bool? = false
    property client_attributes : ClientAttributeType = ClientAttributeType.new

    def initialize(options = NamedTuple.new)
      options.each do |key, value|
        write_attr key, value
      end
    end

    def parse(text)
      array = text.delete("\n").scan(/([A-z0-9-]+)\s*=\s*("[^"]*"|[^,]*)/)
      array.each do |arr|
        key, value = arr[1], arr[2]

        case value
        # float
        when /^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$/
          write_attr(key, value.to_f)
        # int
        when /^([+-]?[0-9]\d*|0)$/
          write_attr(key, value.to_i)
        # bool
        when "true", "false"
          write_attr(key, value.to_boolean)
        else
          write_attr(key, value.delete('"'))
        end
      end
    end

    def write_attr(key, value)
      case value
      when String
        case key
        when :id, "ID"
          @id = value
        when :class_name, "CLASS"
          @class_name = value
        when :start_date, "START-DATE"
          @start_date = value
        when :end_date, "END-DATE"
          @end_date = value
        when :duration, "DURATION"
          @duration = value.to_f
        when :planned_duration, "PLANNED-DURATION"
          @planned_duration = value.to_f
        when :scte35_cmd, "SCTE35-CMD"
          @scte35_cmd = value
        when :scte35_out, "SCTE35-OUT"
          @scte35_out = value
        when :scte35_in, "SCTE35-IN"
          @scte35_in = value
        when :end_on_next, "END-ON-NEXT"
          @end_on_next = value.to_boolean
        when /^X-/
          @client_attributes[key] = value
        end

      when Float64
        case key
        when :duration, "DURATION"
          @duration = value
        when :planned_duration, "PLANNED-DURATION"
          @planned_duration = value
        when /^X-/
          @client_attributes[key] = value
        end

      when Bool
        case key
        when :end_on_next, "END-ON-NEXT"
          @end_on_next = value
        when /^X-/
          @client_attributes[key] = value
        end

      when Hash
        case key
        when :client_attributes
          parse_client_attributes(value).each do |k, v|
            write_attr(k, v)
          end
        end

      end
    end

    def to_s
      "#EXT-X-DATERANGE:#{formatted_attributes.join(',')}"
    end

    def formatted_attributes
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
      return if class_name.nil?
      %(CLASS="#{class_name}")
    end

    private def start_date_format
      return if start_date.nil?
      %(START-DATE="#{start_date}")
    end

    private def end_date_format
      return if end_date.nil?
      %(END-DATE="#{end_date}")
    end

    private def duration_format
      return if duration.nil?
      "DURATION=#{duration}"
    end

    private def planned_duration_format
      return if planned_duration.nil?
      "PLANNED-DURATION=#{planned_duration}"
    end

    private def scte35_cmd_format
      return if scte35_cmd.nil?
      "SCTE35-CMD=#{scte35_cmd}"
    end

    private def scte35_out_format
      return if scte35_out.nil?
      "SCTE35-OUT=#{scte35_out}"
    end

    private def scte35_in_format
      return if scte35_in.nil?
      "SCTE35-IN=#{scte35_in}"
    end

    private def end_on_next_format
      return unless end_on_next
      "END-ON-NEXT=YES"
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
