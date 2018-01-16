require "./spec_helper"

module M3U8
  describe Scanner do

    {
      {
        "#foo\n" \
        "#bar\n" \
        "#qxz",
        ["#foo", "#bar", "#qxz"],
        [1, 2, 3]
      },
      {
        "#foo\n\n" \
        "#bar\n\n" \
        "#qxz",
        ["#foo", "#bar", "#qxz"],
        [1, 3, 5]
      },
      {
        "#foo\n" \
        "bar\n"  \
        "qxz",
        ["#foobarqxz"],
        [1]
      },
      {
        "#foo \\\n" \
        "bar  \\\n" \
        "qxz",
        ["#foobarqxz"],
        [1]
      },
      {
        "#foo \\\n" \
        "#bar \\\n" \
        "#qxz",
        ["#foo#bar#qxz"],
        [1]
      },
      {
        "#foo\n\n" \
        "bar\n\n"  \
        "qxz",
        ["#foobarqxz"],
        [1]
      }
    }.each do |(string, paragraphs, paragraphs_lineno)|
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

        it "prev_index" do
          scanner.prev_index.should eq -1
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
          scanner.index = scanner.max_index + 1
          scanner.eof?.should be_true

          scanner.rewind
          scanner.eof?.should be_false
        end

        it "#current_line" do
          scanner = Scanner.new string
          scanner.current_line.should eq string.lines[0]
          scanner.next
          scanner.current_line.should eq string.lines[1]
          scanner.prev
          scanner.current_line.should eq string.lines[0]
        end

        it "#next" do
          scanner.next.should eq string.lines[1]
        end

        it "#prev" do
          scanner.prev.should eq string.lines[0]
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
          scanner.index = scanner.max_index + 1
          scanner.peek.should eq nil
          scanner.rewind
        end

        it "rewind" do
          first_peek = scanner.peek
          second_peek = scanner.peek
          first_peek.should_not eq second_peek

          scanner.peek_rewind
          scanner.peek.should eq first_peek
        end
      end

      describe "buffer" do
        it "initialize" do
          scanner = Scanner.new string
          scanner.buffer.should eq ""
        end

        describe "add buffer" do
          it "#next" do
            scanner = Scanner.new(string)
            scanner.next
            scanner.buffer.should eq string.lines[0]
            scanner.next
            scanner.buffer.should eq string.lines[0..1].join
          end

          it "#prev" do
            scanner = Scanner.new(string)
            scanner.prev
            scanner.buffer.should eq string.lines[0]
            scanner.prev
            scanner.buffer.should eq string.lines[0] + string.lines[-1]
          end

          it "#lineno=" do
            scanner = Scanner.new(string)
            scanner.lineno = 2
            scanner.buffer.should eq string.lines[0]
            scanner.lineno = 3
            scanner.buffer.should eq string.lines[0..1].join
          end

          it "#index=" do
            scanner = Scanner.new(string)
            scanner.index = 1
            scanner.buffer.should eq string.lines[0]
            scanner.index = 2
            scanner.buffer.should eq string.lines[0..1].join
          end
        end

        it "clear" do
          scanner = Scanner.new(string)
          scanner.next
          scanner.buffer.should eq string.lines[0]
          scanner.clear
          scanner.buffer.should eq ""
        end
      end

      describe "reset" do
        scanner = Scanner.new(string)

        it "index" do
          scanner.next
          scanner.index.should eq 1
          scanner.reset
          scanner.index.should eq 0
        end

        it "buffer" do
          scanner.next
          scanner.buffer.should eq string.lines[0]
          scanner.reset
          scanner.buffer.should eq ""
        end
      end

      describe "each" do
        scanner = Scanner.new(string)

        it "paragraph with index" do
          scanner.each_paragraph do |line, index|
            line.should eq paragraphs[index]
          end
        end

        it "paragraph with index" do
          numbers = paragraphs_lineno.clone
          scanner.each_paragraph do |line, index, lineno|
            numbers.delete(lineno).should eq lineno
          end
        end

        it "paragraph" do
          parts = paragraphs.clone
          scanner.each_paragraph do |line|
            line.should eq parts.shift
          end
        end

        it "line" do
          index = 0
          scanner.each do |line|
            line.should eq string.lines[index]
            index += 1
          end
        end

        it "line with index" do
          scanner.each do |line, index|
            line.should eq string.lines[index]
          end
        end
      end
    end
  end
end
