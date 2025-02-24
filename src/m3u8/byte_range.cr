module M3U8
  # `ByteRange` represents a sub-range of a resource.
  #
  # In HTTP Live Streaming, the `EXT-X-BYTERANGE` tag ([RFC 8216, Section 4.3.2.2](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.2.2))
  # indicates that a Media Segment is a sub-range of the resource identified by its URI.
  #
  # Its format is:
  #
  # ```txt
  # #EXT-X-BYTERANGE:<length>[@<start>]
  # ```
  #
  # where:
  #   - `length` is a decimal integer indicating the length of the sub-range in bytes.
  #   - `start` (optional) is a decimal integer indicating the start of the sub-range
  #     as a byte offset from the beginning of the resource.
  #
  # If `start` is not provided, then the sub-range begins at the next byte following the
  # sub-range of the previous Media Segment. In that case, a previous Media Segment
  # MUST appear in the Playlist and be a sub-range of the same media resource; otherwise,
  # the Media Segment is undefined and the client MUST fail to parse the Playlist.
  #
  # Note: A Media Segment without an `EXT-X-BYTERANGE` tag consists of the entire
  # resource identified by its URI. Use of the `EXT-X-BYTERANGE` tag requires a
  # compatibility version number of 4 or greater.
  class ByteRange
    include Concern

    # The length of the sub-range in bytes.
    property length : Int32?

    # The start of the sub-range as a byte offset from the beginning of the resource.
    property start : Int32?

    # Parses the given item into a `ByteRange`.
    #
    # Examples:
    #
    # ```
    # ByteRange.parse(ByteRange.new(length: 4500, start: 600))
    # ByteRange.parse({length: 4500, start: 600})
    # ByteRange.parse("4500@600")
    # ByteRange.parse
    # ```
    def self.parse(item = nil)
      case item
      when String     then new(item)
      when NamedTuple then new(item)
      when ByteRange  then item
      else                 new
      end
    end

    # Creates a new `ByteRange` from a string.
    #
    # Examples:
    #
    # ```
    # ByteRange.new("4500@600")
    # ByteRange.new("4500")
    # ```
    def self.new(string : String)
      return new if string.empty?

      values = string.split('@').map &.to_i
      new(values[0]?, values[1]?)
    end

    # Creates a new `ByteRange` from a NamedTuple.
    #
    # Examples:
    #
    # ```
    # options = {length: 4500, start: 600}
    # ByteRange.new(options)
    # ByteRange.new(length: 4500, start: 600)
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        length: params[:length]?,
        start: params[:start]?,
      )
    end

    # Creates an empty `ByteRange`.
    #
    # Example:
    #
    # ```
    # ByteRange.new
    # ```
    def initialize(@length = nil, @start = nil)
    end

    # Returns whether the `ByteRange` is empty.
    #
    # A `ByteRange` is considered empty if its length is `nil` or zero.
    #
    # Examples:
    #
    # ```
    # byterange = ByteRange.new
    # byterange.empty? # => true
    # byterange = ByteRange.new(length: 0)
    # byterange.empty? # => true
    # byterange.length = 4500
    # byterange.empty? # => false
    # ```
    def empty?
      length = @length
      length.nil? || length.zero?
    end

    # Returns a string representation of the `ByteRange`.
    #
    # The representation is the length, followed by the start (if provided)
    # separated by an `@`.
    #
    # Examples:
    #
    # ```
    # byterange = ByteRange.new(length: 4500, start: 600)
    # byterange.to_s # => "4500@600"
    # byterange = ByteRange.new(length: 4500)
    # byterange.to_s # => "4500"
    # byterange = ByteRange.new
    # byterange.to_s # => ""
    # ```
    def to_s
      attributes.join('@')
    end

    # Compares this `ByteRange` with a String.
    #
    # The `ByteRange` is equal to the string if their string representations match.
    #
    # Example:
    #
    # ```
    # left = ByteRange.new(length: 4500, start: 600)
    # right = "4500@600"
    # left == right # => true
    # ```
    def ==(other : String)
      to_s == other
    end

    # Compares this `ByteRange` with a NamedTuple.
    #
    # It creates a new `ByteRange` from the NamedTuple and compares their string
    # representations.
    #
    # Example:
    #
    # ```
    # left = ByteRange.new(length: 4500, start: 600)
    # right = {length: 4500, start: 600}
    # left == right # => true
    # ```
    def ==(other : NamedTuple)
      to_s == ByteRange.new(other).to_s
    end

    # Compares this `ByteRange` with another `ByteRange`.
    #
    # Two `ByteRange`s are equal if their string representations are equal.
    #
    # Example:
    #
    # ```
    # left = ByteRange.new(length: 4500, start: 600)
    # right = ByteRange.new(length: 4500, start: 600)
    # left == right # => true
    # ```
    def ==(other : ByteRange)
      to_s == other.to_s
    end

    private def attributes
      [
        length_format,
        start_format,
      ].compact
    end

    private def length_format
      "#{length}"
    end

    private def start_format
      "#{start}" unless start.nil?
    end
  end
end
