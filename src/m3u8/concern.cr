module M3U8
  private module Concern
    private macro included
      extend Concern
    end

    # Parses an attribute list from a line.
    #
    # The line is expected to contain a comma-separated list of attribute/value
    # pairs in the format:
    #
    # ```txt
    #   Key=Value
    #   Key=Value,Key="Value"
    # ```
    #
    # where the Value may be quoted.
    #
    # Returns a Hash mapping attribute names (as Strings) to their unquoted values.
    #
    # Example:
    #
    # ```crystal
    # include Concern
    # parse_attributes("Key=Value") # => {"Key" => "Value"}
    # parse_attributes("Key=\"Quoted Value\"") # => {"Key" => "Quoted Value"}
    # ```
    private def parse_attributes(line : String)
      array = line.scan(/([A-z0-9-]+)\s*=\s*("[^"]*"|[^,]*)/)
      array.map { |reg| [reg[1], reg[2].delete('"')] }.to_h
    end

    # Parses client-specific attributes from a given attribute Hash.
    #
    # It iterates over the attributes and selects those whose keys start with `X-`
    # (indicating client-defined attributes). If a value is a String, it is further
    # processed by `parse_token` to convert numeric and boolean values.
    #
    # Returns a hash of the parsed client attributes.
    #
    # Example:
    #
    # ```crystal
    # include Concern
    # options = {
    #   "X-CUSTOM" => "Client Attributes",
    #   "CUSTOM" => "Not Client Attributes",
    # }
    # parse_client_attributes(options)  # => {"X-CUSTOM" => "Client Attributes"}
    # ```
    private def parse_client_attributes(attributes : Hash?)
      hash = ClientAttributeType.new
      return hash if !attributes

      attributes.each do |key, value|
        next unless key.is_a?(String) && key.starts_with?("X-")

        value = parse_token(value) if value.is_a?(String)

        hash[key] = value
      end
      hash
    end

    # Attempts to parse a token string into a more specific type.
    #
    # The conversion is performed in the following order:
    #   1. Check if the token can be fully interpreted as an Integer.
    #      If so, return it as an Integer.
    #   2. Otherwise, check if the token can be interpreted as a Float.
    #      If so, return it as a Float.
    #   3. If the token is exactly "true" or "false", return the corresponding boolean.
    #   4. If the token is empty, return an empty string.
    #   5. Otherwise, return the token unchanged.
    #
    # This ordering ensures that tokens representing whole numbers (e.g. "42")
    # are converted to an integer rather than a float.
    #
    # Example:
    #
    # ```crystal
    # include Concern
    # parse_token("42")    # => 42
    # parse_token("42.3")  # => 42.3
    # parse_token("true")  # => true
    # parse_token("false") # => false
    # parse_token("")      # => ""
    # parse_token("test")  # => "test"
    # ```
    private def parse_token(token : String)
      case token
      when .to_i?  then token.to_i
      when .to_f?  then token.to_f
      when "true"  then true
      when "false" then false
      when .empty? then ""
      else              token
      end
    end

    # Parses a resolution string formatted as "widthxheight".
    #
    # The method splits the input string by the "x" character and attempts to convert
    # each resulting part to a integer. It first tries to convert a part to an integer;
    # if that fails, it tries to convert it to a float (which is then truncated to an integer).
    # If a part cannot be converted, its value is `nil`.
    #
    # Returns a Hash with keys `:width` and `:height`.
    #
    # Examples:
    #
    # ```crystal
    # parse_resolution("1280.0x720.0")   # => {width: 1280, height: 720}
    # parse_resolution("1280x720")       # => {width: 1280, height: 720}
    # parse_resolution("1280")           # => {width: 1280, height: nil}
    # parse_resolution("axb")            # => {width: nil, height: nil}
    # parse_resolution("ab")             # => {width: nil, height: nil}
    # parse_resolution("")               # => {width: nil, height: nil}
    # parse_resolution(nil)              # => {width: nil, height: nil}
    # ```
    private def parse_resolution(resolution : String?)
      return {width: nil, height: nil} if resolution.nil?

      values = resolution.split('x')

      # Append an empty string to ensure there are at least two elements.
      values.push("")

      width  = nil
      height = nil

      # Attempt to convert the width part first to an integer.
      case values[0]
      when .to_i?  then width = values[0].to_i
      when .to_f?  then width = values[0].to_f.to_big_i.to_i
      end

      # Attempt to convert the height part similarly.
      case values[1]
      when .to_i?  then height = values[1].to_i
      when .to_f?  then height = values[1].to_f.to_big_i.to_i
      end

      {
        width: width,
        height: height,
      }
    end

    # Parses a frame rate string into a `BigDecimal`.
    #
    # This method attempts to convert the given `frame_rate` string into a `BigDecimal`.
    # If the frame_rate is `nil` or the resulting value is not greater than 0, the method returns nil.
    #
    # Examples:
    #
    # ```crystal
    # parse_frame_rate("29.97")   # => 29.97
    # parse_frame_rate("0")       # => nil
    # parse_frame_rate(nil)       # => nil
    # ```
    private def parse_frame_rate(frame_rate : String?)
      return if frame_rate.nil?

      value = BigDecimal.new(frame_rate)
      value if value > 0
    end

    # Converts a boolean value to its corresponding "YES" or "NO" string.
    #
    # If the input is true, returns "YES"; if false, returns "NO".
    #
    # Examples:
    #
    # ```crystal
    # parse_yes_no(true)   # => "YES"
    # parse_yes_no(false)  # => "NO"
    # parse_yes_no(nil)    # => nil
    # ```
    private def parse_yes_no(value : Bool?)
      case value
      when true  then "YES"
      when false then "NO"
      end
    end

    # Parses a string representing a boolean value in a **case-insensitive** manner.
    #
    # The method converts the input to lowercase before checking.
    # It returns `true` if the input is "true" or "yes", `false` if it is "false" or "no",
    # and returns `nil` if the input does not match any of these values.
    #
    # Examples:
    #
    # ```crystal
    # parse_boolean("true")   # => true
    # parse_boolean("YES")    # => true
    # parse_boolean("True")   # => true
    # parse_boolean("false")  # => false
    # parse_boolean("NO")     # => false
    # parse_boolean("maybe")  # => nil
    # parse_boolean(nil)      # => nil
    # ```
    private def parse_boolean(value : String?)
      return nil if value.nil?

      case value.downcase
      when "true", "yes" then true
      when "false", "no" then false
      else nil
      end
    end

    # A fallback macro for missing methods.
    #
    # This macro is invoked when a method is called that is not defined in the context
    # of the including module. It simply returns nil, allowing the program to continue
    # without raising a NoMethodError.
    #
    # Example:
    #
    # Suppose a class includes Concern (which defines this macro) but does not define a method `foo`:
    #
    # ```crystal
    # class Dummy
    #   include Concern
    # end
    #
    # dummy = Dummy.new
    # dummy.foo  # => nil (since `foo` is missing, method_missing returns nil)
    # ```
    private macro method_missing(call)
      nil
    end
  end
end
