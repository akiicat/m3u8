require "json"

module M3U8
  # `DateRangeItem` encapsulates an `EXT-X-DATERANGE` tag in an HLS playlist.
  #
  # As defined in [RFC 8216, Section 4.3.2.7](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.2.7),
  # the `XT-X-DATERANGE` tag is used to associate a specific date range with a collection of
  # attribute/value pairs. It is typically used for signaling events
  # such as ad insertion, content segmentation, or SCTE-35 splice points.
  #
  # Example tag format:
  #
  # ```txt
  # #EXT-X-DATERANGE:ID="...",CLASS="...",START-DATE="...",END-DATE="...",...
  # ```
  #
  # The `EXT-X-DATERANGE` tag stores the following attributes:
  # - **ID** (required): A unique identifier for the date range.
  # - **CLASS** (optional): A client-defined category for the date range.
  # - **START-DATE** (required): The starting date/time in [ISO-8601](https://xml.coverpages.org/ISO-FDIS-8601.pdf) format.
  # - **END-DATE** (optional): The ending date/time in [ISO-8601](https://xml.coverpages.org/ISO-FDIS-8601.pdf) format.
  # - **DURATION** (optional): The duration of the date range, in seconds.
  # - **PLANNED-DURATION** (optional): The expected duration, in seconds.
  # - **SCTE35-CMD, SCTE35-OUT, SCTE35-IN** (optional): Attributes carrying SCTE-35 splice data.
  # - **END-ON-NEXT** (optional): A boolean flag that, if true, outputs `"END-ON-NEXT=YES"`.
  # - **Client-specific attributes** (optional): Any additional attributes with keys starting with `X-`.
  class DateRangeItem
    include Concern

    # A unique identifier for the date range.
    property id : String?

    # The start date/time in [ISO-8601](https://xml.coverpages.org/ISO-FDIS-8601.pdf) format.
    property start_date : String?

    # A client-defined category for the date range.
    property class_name : String?

    # The end date/time in [ISO-8601](https://xml.coverpages.org/ISO-FDIS-8601.pdf) format.
    property end_date : String?

    # The duration in seconds.
    property duration : Float64?

    # The expected duration in seconds.
    property planned_duration : Float64?

    # SCTE-35 splice information.
    property scte35_cmd : String?

    # SCTE-35 splice information.
    property scte35_out : String?

    # SCTE-35 splice information.
    property scte35_in : String?

    # A boolean flag; if true, outputs `"END-ON-NEXT=YES"`.
    property end_on_next : Bool?

    # Client-specific attributes (those whose keys start with `X-`).
    property client_attributes : ClientAttributeType

    # Parses a complete `EXT-X-DATERANGE` tag line and returns a new `DateRangeItem`.
    #
    # The tag line is expected to follow the format defined in [RFC 8216](https://datatracker.ietf.org/doc/html/rfc8216):
    #
    # ```txt
    #   #EXT-X-DATERANGE:ID="...",CLASS="...",START-DATE="...",END-DATE="...",...
    # ```
    #
    # Examples:
    #
    # ```crystal
    # text = %(#EXT-X-DATERANGE:ID="test_id",CLASS="test_class",\
    #        START-DATE="2014-03-05T11:15:00Z",END-DATE="2014-03-05T11:16:00Z",\
    #        DURATION=60.1,PLANNED-DURATION=59.993,X-CUSTOM=45.3,\
    #        SCTE35-CMD=0xFC002F0000000000FF2,SCTE35-OUT=0xFC002F0000000000FF0,\
    #        SCTE35-IN=0xFC002F0000000000FF1,END-ON-NEXT=YES)
    # DateRangeItem.parse(text)
    # # => #<M3U8::DateRangeItem:0x7d6bff706f00
    # #     @class_name="test_class",
    # #     @client_attributes={"X-CUSTOM" => 45.3},
    # #     @duration=60.1,
    # #     @end_date="2014-03-05T11:16:00Z",
    # #     @end_on_next=true,
    # #     @id="test_id",
    # #     @planned_duration=59.993,
    # #     @scte35_cmd="0xFC002F0000000000FF2",
    # #     @scte35_in="0xFC002F0000000000FF1",
    # #     @scte35_out="0xFC002F0000000000FF0",
    # #     @start_date="2014-03-05T11:15:00Z">
    # ```
    def self.parse(text : String)
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
        end_on_next: parse_boolean(params["END-ON-NEXT"]?),
        client_attributes: parse_client_attributes(params),
      )
    end

    # Creates a new `DateRangeItem` from a NamedTuple of parameters.
    #
    # The NamedTuple keys should match the attribute names (using symbols):
    # - `id`
    # - `start_date`
    # - `class_name`
    # - `end_date`
    # - `duration`
    # - `planned_duration`,
    # - `scte35_cmd`
    # - `scte35_out`
    # - `scte35_in`
    # - `end_on_next`
    # - `client_attributes`.
    #
    # Examples:
    #
    # ```crystal
    # options = {
    #   id:                "test_id",
    #   start_date:        "2014-03-05T11:15:00Z",
    #   class_name:        "test_class",
    #   end_date:          "2014-03-05T11:16:00Z",
    #   duration:          60.1,
    #   planned_duration:  59.993,
    #   scte35_out:        "0xFC002F0000000000FF0",
    #   scte35_in:         "0xFC002F0000000000FF1",
    #   scte35_cmd:        "0xFC002F0000000000FF2",
    #   end_on_next:       true,
    #   client_attributes: {"X-CUSTOM" => 45.3},
    # }
    # DateRangeItem.new(options)
    # # => #<M3U8::DateRangeItem:0x7d6bff706f00
    # #     @class_name="test_class",
    # #     @client_attributes={"X-CUSTOM" => 45.3},
    # #     @duration=60.1,
    # #     @end_date="2014-03-05T11:16:00Z",
    # #     @end_on_next=true,
    # #     @id="test_id",
    # #     @planned_duration=59.993,
    # #     @scte35_cmd="0xFC002F0000000000FF2",
    # #     @scte35_in="0xFC002F0000000000FF1",
    # #     @scte35_out="0xFC002F0000000000FF0",
    # #     @start_date="2014-03-05T11:15:00Z">
    # ```
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

    # Initializes a new `DateRangeItem` instance.
    #
    # The instance variables are directly set from the constructor arguments.
    #
    # Example:
    #
    # ```crystal
    # DateRangeItem.new
    # ```
    def initialize(@id = nil, @start_date = nil, @class_name = nil, @end_date = nil, @duration = nil, @planned_duration = nil,
                   @scte35_cmd = nil, @scte35_out = nil, @scte35_in = nil, @end_on_next = nil, client_attributes = nil)
      @client_attributes = parse_client_attributes(client_attributes)
    end

    # Returns the string representation of the `EXT-X-DATERANGE` tag.
    #
    # The output is constructed by concatenating all formatted attribute strings
    # (e.g. ID, CLASS, START-DATE, etc.) separated by commas, and prefixed with
    # `#EXT-X-DATERANGE:`.
    #
    # Example:
    #
    # ```crystal
    # options = {
    #   id:                "test_id",
    #   start_date:        "2014-03-05T11:15:00Z",
    #   class_name:        "test_class",
    #   end_date:          "2014-03-05T11:16:00Z",
    #   duration:          60.1,
    #   planned_duration:  59.993,
    #   scte35_out:        "0xFC002F0000000000FF0",
    #   scte35_in:         "0xFC002F0000000000FF1",
    #   scte35_cmd:        "0xFC002F0000000000FF2",
    #   end_on_next:       true,
    #   client_attributes: {"X-CUSTOM" => 45.3},
    # }
    # DateRangeItem.new(options).to_s
    # # => #(EXT-X-DATERANGE:ID="test_id",CLASS="test_class",START-DATE="2014-03-05T11:15:00Z",
    # #      END-DATE="2014-03-05T11:16:00Z",DURATION=60.1,PLANNED-DURATION=59.993,
    # #      X-CUSTOM="45.3",SCTE35-CMD=0xFC002F0000000000FF2,
    # #      SCTE35-OUT=0xFC002F0000000000FF0,SCTE35-IN=0xFC002F0000000000FF1,
    # #      END-ON-NEXT=YES)
    # ```
    def to_s
      "#EXT-X-DATERANGE:#{attributes.join(',')}"
    end

    private def attributes
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
        end_on_next_format,
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

    # Formats client-specific attributes (keys beginning with "X-") as a comma-
    # separated list of key=value pairs. String values are quoted.
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
