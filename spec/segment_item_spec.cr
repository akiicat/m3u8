require "./spec_helper"

module M3U8
  describe SegmentItem do

    describe "initialize" do
      options = {
        duration: 10.991,
        segment: "test.ts",
        comment: "anything",
        byterange: { length: 4500, start: 600 }
      }
      expected = %(#EXTINF:10.991,anything\n#EXT-X-BYTERANGE:4500@600\ntest.ts)

      pending "hash" do
        SegmentItem.new(options.to_h).to_s.should eq expected
      end

      it "namedtuple" do
        SegmentItem.new(options).to_s.should eq expected
      end

      it "hash like" do
        SegmentItem.new(**options).to_s.should eq expected
      end
    end

    {
      {
        NamedTuple.new,
        %(#EXTINF:,)
      },
      {
        {
          duration: 10.991,
          segment: "test.ts",
          comment: "anything",
          byterange: {
            length: 4500,
            start: 600
          }
        },
        %(#EXTINF:10.991,anything\n#EXT-X-BYTERANGE:4500@600\ntest.ts)
      },
      {
        {
          duration: 10.991,
          segment: "test.ts",
          comment: "anything",
          byterange: ByteRange.new(length: 4500, start: 600)
        },
        %(#EXTINF:10.991,anything\n#EXT-X-BYTERANGE:4500@600\ntest.ts)
      },
      {
        {
          duration: 10.991,
          segment: "test.ts",
          comment: "anything",
          byterange: {
            length: 4500
          }
        },
        %(#EXTINF:10.991,anything\n#EXT-X-BYTERANGE:4500\ntest.ts)
      },
      {
        {
          duration: 10.991,
          segment: "test.ts",
          comment: "anything",
          byterange: ByteRange.new(length: 4500)
        },
        %(#EXTINF:10.991,anything\n#EXT-X-BYTERANGE:4500\ntest.ts)
      },
      {
        {
          duration: 10.991,
          segment: "test.ts",
          comment: "anything"
        },
        %(#EXTINF:10.991,anything\ntest.ts)
      },
      {
        {
          duration: 10.991,
          segment: "test.ts",
          program_date_time: "2010-02-19T06:54:23.031Z"
        },
        %(#EXTINF:10.991,\n#EXT-X-PROGRAM-DATE-TIME:2010-02-19T06:54:23.031Z\ntest.ts)
      },
      {
        {
          duration: 10.991,
          segment: "test.ts",
          program_date_time: Time.iso8601("2010-02-19T06:54:23.031Z")
        },
        %(#EXTINF:10.991,\n#EXT-X-PROGRAM-DATE-TIME:2010-02-19T06:54:23.031Z\ntest.ts)
      },
      {
        {
          duration: 10.991,
          segment: "test.ts"
        },
        %(#EXTINF:10.991,\ntest.ts)
      }
    }.each do |(params, format)|
      item = SegmentItem.new(params)
      
      describe "initialize" do
        it "duration" do
          item.duration.should eq params[:duration]?
        end

        it "segment" do
          item.segment.should eq params[:segment]?
        end

        it "comment" do
          item.comment.should eq params[:comment]?
        end

        it "byterange" do
          item.byterange.should be_a ByteRange
        end

        it "program_date_time" do
          exist = params[:program_date_time]? ? TimeItem : Nil
          item.program_date_time.class.should eq exist
        end
      end

      it "to_s" do
        item.to_s.should eq format
      end
    end
  end
end

