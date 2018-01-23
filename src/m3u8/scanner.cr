module M3U8
  class Scanner
    getter index : Int32
    property peek_index : Int32
    getter reader : Array(String)
    getter max_index : Int32
    getter size : Int32

    def initialize(string : String = "")
      @reader = string.lines.map { |line| line.strip }
      @index = 0
      @peek_index = 0
      @size = @reader.size
      @max_index = size - 1
    end

    def index=(index)
      set(index)
    end

    def prev_index
      @index - 1
    end

    def next_index
      @index + 1
    end

    def eof?
      @index > max_index
    end

    def rewind
      set(0)
    end

    def current_line
      get(@index)
    end

    def prev_line
      get(prev_index)
    end

    def next_line
      get(next_index)
    end

    def next
      move(1)
    end

    def prev
      move(-1)
    end

    def peek
      @peek_index += 1
      get(@peek_index)
    end

    def peek_rewind
      @peek_index = @index
    end

    def lineno
      @index + 1
    end

    def lineno=(number)
      set(number - 1)
    end

    def first
      get(0)
    end

    def last
      get(-1)
    end

    def [](index : Int32)
      get(index)
    end

    private def get(index : Int32) : String
      @reader[index]? || ""
    end

    private def set(index : Int32, offset : Int32 = 0) : String?
      @index = index + offset
      peek_rewind
      get(@index)
    end

    private def move(offset : Int32) : String?
      set(@index, offset)
    end
  end
end
