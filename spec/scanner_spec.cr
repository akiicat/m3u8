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

        it "first" do
          scanner.first.should eq string.lines[0]
        end

        it "last" do
          scanner.last.should eq string.lines[-1]
        end

        it "#[]" do
          scanner[1].should eq string.lines[1]
        end

        it "#[] out of bound" do
          scanner[9].should eq ""
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
          scanner.current_line.should eq ""
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
          scanner.peek.should eq ""
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
    end
  end
end
