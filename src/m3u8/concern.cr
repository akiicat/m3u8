module M3U8
  module Concern

    private def parse_time(time)
      case time
      when String then Time.iso8601(time)
      when Time then time
      end.not_nil!
    end

    private def parse_byterange(item)
      case item
      when NamedTuple then ByteRange.new(item)
      when ByteRange then item
      end
    end

    private def parse_time_item(item)
      case item
      when String, Time then TimeItem.new item
      when TimeItem then item
      end
    end
  end
end
