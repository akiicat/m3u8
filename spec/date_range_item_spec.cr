require "./spec_helper"

module M3U8
  describe DateRangeItem do

    describe "initialize" do
      options = {
        id: "test_id",
        start_date: "2014-03-05T11:15:00Z",
        class_name: "test_class",
        end_date: "2014-03-05T11:16:00Z",
        duration: 60.1,
        planned_duration: 59.993,
        scte35_out: "0xFC002F0000000000FF0",
        scte35_in: "0xFC002F0000000000FF1",
        scte35_cmd: "0xFC002F0000000000FF2",
        end_on_next: true,
        client_attributes: { "X-CUSTOM" => 45.3 }
      }
      expected = %(#EXT-X-DATERANGE:ID="test_id",CLASS="test_class",START-DATE="2014-03-05T11:15:00Z",END-DATE="2014-03-05T11:16:00Z",DURATION=60.1,PLANNED-DURATION=59.993,X-CUSTOM=45.3,SCTE35-CMD=0xFC002F0000000000FF2,SCTE35-OUT=0xFC002F0000000000FF0,SCTE35-IN=0xFC002F0000000000FF1,END-ON-NEXT=YES)

      pending "hash" do
        DateRangeItem.new(options.to_h).to_s.should eq expected
      end

      it "namedtuple" do
        DateRangeItem.new(options).to_s.should eq expected
      end

      it "hash like" do
        DateRangeItem.new(**options).to_s.should eq expected
      end
    end

    {
      {
        {
          id: "test_id",
          start_date: "2014-03-05T11:15:00Z",
          class_name: "test_class",
          end_date: "2014-03-05T11:16:00Z",
          duration: 60.1,
          planned_duration: 59.993,
          scte35_out: "0xFC002F0000000000FF0",
          scte35_in: "0xFC002F0000000000FF1",
          scte35_cmd: "0xFC002F0000000000FF2",
          end_on_next: true,
          client_attributes: { "X-CUSTOM" => 45.3 }
        },
        %(#EXT-X-DATERANGE:ID="test_id",CLASS="test_class",START-DATE="2014-03-05T11:15:00Z",END-DATE="2014-03-05T11:16:00Z",DURATION=60.1,PLANNED-DURATION=59.993,X-CUSTOM=45.3,SCTE35-CMD=0xFC002F0000000000FF2,SCTE35-OUT=0xFC002F0000000000FF0,SCTE35-IN=0xFC002F0000000000FF1,END-ON-NEXT=YES)
      },
      {
        {
          id: "test_id",
          start_date: "2014-03-05T11:15:00Z",
          class_name: "test_class",
          end_date: "2014-03-05T11:16:00Z",
          duration: 60.1,
          planned_duration: 59.993,
          scte35_out: "0xFC002F0000000000FF0",
          scte35_in: "0xFC002F0000000000FF1",
          scte35_cmd: "0xFC002F0000000000FF2",
          end_on_next: true,
          client_attributes: {
            "X-CUSTOM" => 45.3,
            "X-CUSTOM-TEXT" => "test_value"
          }
        },
        %(#EXT-X-DATERANGE:ID="test_id",CLASS="test_class",) \
        %(START-DATE="2014-03-05T11:15:00Z",) \
        %(END-DATE="2014-03-05T11:16:00Z",DURATION=60.1,) \
        %(PLANNED-DURATION=59.993,) \
        %(X-CUSTOM=45.3,) \
        %(X-CUSTOM-TEXT="test_value",) \
        %(SCTE35-CMD=0xFC002F0000000000FF2,) \
        %(SCTE35-OUT=0xFC002F0000000000FF0,) \
        %(SCTE35-IN=0xFC002F0000000000FF1,) \
        %(END-ON-NEXT=YES)
      },
      {
        {
          id: "test_id",
          start_date: "2014-03-05T11:15:00Z"
        },
        %(#EXT-X-DATERANGE:ID="test_id",) \
        %(START-DATE="2014-03-05T11:15:00Z")
      }
    }.each do |(params, format)|
      item = DateRangeItem.new(params)

      describe "initialize" do
        assets_attributes item, params
      end

      it "to_s" do
        item.to_s.should eq format
      end

      describe "parse" do
        item = DateRangeItem.parse(format)
        assets_attributes item, params
      end
    end
  end
end

private def assets_attributes(item, params)
  it "id" do
    item.id.should eq params[:id]
  end

  it "class_name" do
    item.class_name.should eq params[:class_name]?
  end

  it "start_date" do
    item.start_date.should eq params[:start_date]
  end

  it "end_date" do
    item.end_date.should eq params[:end_date]?
  end

  it "duration" do
    item.duration.should eq params[:duration]?
  end

  it "planned_duration" do
    item.planned_duration.should eq params[:planned_duration]?
  end

  it "scte35_out" do
    item.scte35_out.should eq params[:scte35_out]?
  end

  it "scte35_in" do
    item.scte35_in.should eq params[:scte35_in]?
  end

  it "scte35_cmd" do
    item.scte35_cmd.should eq params[:scte35_cmd]?
  end

  it "end_on_next" do
    item.end_on_next.should eq params[:end_on_next]?
  end

  describe "client_attributes" do
    item.client_attributes.each do |key, value|
      it "#{key} => #{value}" do
        client_attributes = params[:client_attributes]?
          value.should eq client_attributes[key] unless client_attributes.nil?
      end
    end
  end
end
