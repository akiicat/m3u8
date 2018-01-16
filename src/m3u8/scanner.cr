module M3U8
  class Scanner
    property reader : Array(String)
    getter index : Int32
    property buffer : String

    def initialize(string : String)
      @reader = string.lines.map { |line| line.strip }

      @index = 0
      @peek_index = 1

      @buffer = current_line.to_s
      # reset
    end

    def index=(idx)
      @index = idx
      peek_reset
    end

    def next_index
      @index + 1
    end

    def max_index
      size - 1
    end

    def size
      @reader.size
    end

    def eof?
      next_index > max_index
    end

    def rewind
      @index = 0
      peek_reset
    end

    def current_line
      @reader[index]?
    end

    def next
      @index += 1
      peek_reset
      @buffer += @reader[index]?.to_s
      current_line
    end

    def peek
      line = @reader[@peek_index]?
      @peek_index += 1
      line
    end

    def clear
      @buffer = ""
    end

    def peek_reset
      @peek_index = next_index
    end

    def reset
      rewind
      clear
    end

    def lineno
      @index + 1
    end

    def lineno=(number)
      @index = number - 1
      peek_reset
    end

    def [](index : Int32)
      @reader[index]?
    end
  end
end
