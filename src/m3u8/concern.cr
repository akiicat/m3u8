module M3U8
  module Concern
    macro included
      extend Concern
    end

    private def parse_attributes(line)
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

    macro method_missing(call)
      nil
    end
  end
end
