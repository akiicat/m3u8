module M3U8
  module Concern
    macro included
      extend Concern
    end

    private def parse_attributes(line : String)
      array = line.scan(/([A-z0-9-]+)\s*=\s*("[^"]*"|[^,]*)/)
      array.map { |reg| [reg[1], reg[2].delete('"')] }.to_h
    end

    private def parse_time(time)
      case time
      when String then Time.iso8601(time)
      when Time then time
      else Time.epoch 0
      end
    end

    private def parse_byterange(item)
      case item
      when String, NamedTuple then ByteRange.new(item)
      when ByteRange then item
      else ByteRange.new
      end
    end

    private def parse_time_item(item)
      case item
      when String, Time then TimeItem.new item
      when TimeItem then item
      else TimeItem.new
      end
    end

    private def parse_client_attributes(attributes)
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
      when .to_f? then token.to_f
      when .to_i? then token.to_i
      when "true" then true
      when "false" then false
      when .empty? then ""
      else token
      end
    end

    macro method_missing(call)
      nil
    end
  end
end
