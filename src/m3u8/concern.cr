module M3U8
  private module Concern
    private macro included
      extend Concern
    end

    private def parse_attributes(line : String)
      array = line.scan(/([A-z0-9-]+)\s*=\s*("[^"]*"|[^,]*)/)
      array.map { |reg| [reg[1], reg[2].delete('"')] }.to_h
    end

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

    private def parse_frame_rate(frame_rate)
      return if frame_rate.nil?

      value = BigDecimal.new(frame_rate)
      value if value > 0
    end

    private def parse_yes_no(value)
      case value
      when true  then "YES"
      when false then "NO"
      end
    end

    private def parse_boolean(value : String?)
      return nil if value.nil?

      case value.downcase
      when "true", "yes" then true
      when "false", "no" then false
      else nil
      end
    end

    private macro method_missing(call)
      nil
    end
  end
end
