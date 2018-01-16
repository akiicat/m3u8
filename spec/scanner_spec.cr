require "./spec_helper"

module M3U8
  describe Scanner do

    {
      {
        "#foo\n" \
        "#bar\n" \
        "#qxz"
      },
      {
        "#foo\n" \
        "bar\n"  \
        "qxz"
      },
      {
        "#foo \\\n" \
        "bar  \\\n" \
        "qxz"
      },
      {
        "#foo\n\n" \
        "bar\n\n"  \
        "qxz"
      }
    }.each do |(string)|
      it "#initialize" do
        scanner = Scanner.new string
        scanner[0].should eq scanner.reader[0]
      end

      describe "position" do
        scanner = Scanner.new string

        it "#index" do
          scanner.index.should eq 0
        end

        it "#index=" do
          scanner.index = 1
          scanner.index.should eq 1
          scanner.index = 0
          scanner.index.should eq 0
        end

        it "next_index" do
          scanner.next_index.should eq 1
        end

        it "#max_index" do
          scanner.max_index.should eq string.lines.size - 1
        end

        it "#size" do
          scanner.size.should eq string.lines.size
        end

        it "#lineno" do
          scanner.lineno.should eq 1
        end

        it "#lineno=" do
          scanner.lineno = 2
          scanner.lineno.should eq 2
          scanner.lineno = 1
          scanner.lineno.should eq 1
        end

        it "#[]" do
          scanner[1].should eq string.lines[1]
        end

        it "#[] out of bound" do
          scanner[9].should be_nil
        end
      end

      describe "line" do
        scanner = Scanner.new string

        it "#eof?" do
          scanner.index = scanner.max_index
          scanner.eof?.should be_true
          scanner.rewind
          scanner.eof?.should be_false
        end

        it "#next" do
          peek_line = scanner.peek
          scanner.next.should eq peek_line
          scanner.index.should eq 1
          scanner.current_line.should eq peek_line
          scanner.rewind
        end

        it "#next out of bound" do
          5.times { scanner.next }
          scanner.current_line.should be_nil
          scanner.rewind
        end

        it "#rewind" do
          scanner.next
          scanner.index.should eq 1
          scanner.rewind
          scanner.index.should eq 0
        end
      end

      describe "peek" do
        scanner = Scanner.new string

        it "one" do
          scanner.peek.should eq string.lines[1]
          scanner.rewind
        end

        it "multiple" do
          scanner.peek.should eq string.lines[1]
          scanner.peek.should eq string.lines[2]
          scanner.rewind
        end

        it "next" do
          scanner.peek.should eq string.lines[1]
          scanner.next
          scanner.peek.should eq string.lines[2]
          scanner.rewind
        end

        it "end of file" do
          scanner.index = scanner.max_index
          scanner.peek.should eq nil
          scanner.rewind
        end
      end

      describe "buffer" do
        it "initialize" do
          scanner = Scanner.new string
          scanner.buffer.should eq string.lines[0]
        end

        it "add buffer" do
          scanner = Scanner.new(string)
          scanner.next
          scanner.buffer.should eq string.lines[0..1].join
        end

        it "clear" do
          scanner = Scanner.new(string)
          scanner.clear
          scanner.buffer.should eq ""
        end
      end

      describe "reset" do
        it "index" do
          scanner = Scanner.new(string)
          scanner.next
          scanner.index.should eq 1
          scanner.reset
          scanner.index.should eq 0
        end

        it "buffer" do
          scanner = Scanner.new(string)
          scanner.next
          scanner.buffer.should eq string.lines[0..1].join
          scanner.reset
          scanner.buffer.should eq ""
        end
      end
    end
  end
end
