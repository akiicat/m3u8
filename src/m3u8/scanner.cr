module M3U8
  class Scanner
    getter index : Int32
    property peek_index : Int32
    property reader : Array(String)
    property buffer : String

    def initialize(string : String = "")
      @reader = string.lines.map { |line| line.strip }
      @buffer = ""
      @index = 0
      @peek_index = 1
    end

    def index=(index)
      move(index: index)
    end

    def prev_index
      @index - 1
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
      @index > max_index
    end

    def rewind
      move(index: 0)
    end

    def current_line
      @reader[@index]? || ""
    end

    def prev_line
      @reader[prev_index]? || ""
    end

    def next_line
      @reader[next_index]? || ""
    end

    def next
      move(offset: 1)
    end

    def prev
      move(offset: -1)
    end

    def peek
      line = @reader[@peek_index]? || ""
      @peek_index += 1
      line
    end

    def clear
      @buffer = ""
    end

    def peek_rewind
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
      move(index: number - 1)
    end

    def [](index : Int32)
      @reader[index]? || ""
    end

    def each(&block)
      @reader.each_with_index do |line, index|
        yield line, index
      end
    end

    def each_paragraph(&block)
      send_box do
        idx, num = 0, 1
        while !eof?
          self.next

          if split?
            yield @buffer, idx, num
            idx, num = idx + 1, next_index
            clear
          else
            @buffer = @buffer.rstrip(" \\")
          end
        end
      end
    end
    
    private def set_index(index : Int32) : Nil
      @index = index
      peek_rewind
    end

    private def push_buffer(index : Int32 = @index) : String
      @buffer += @reader[index]?.to_s
    end

    private def move(index : Int32 = @index, offset : Int32 = 0) : String?
      push_buffer
      set_index index + offset
      current_line
    end

    private def send_box(&block)
      a, b, c = @buffer, @index, @peek_index
      reset
      yield
      @buffer, @index, @peek_index = a, b, c
    end

    private def split? : Bool
      prev = prev_line
      curr = current_line

      !(prev && prev.ends_with?("\\") || curr && !curr.starts_with?("#"))
    end
  end
end
