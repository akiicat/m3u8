require "./spec_helper"

private def date_range_assets(item, expected)

  {% for key, index in %w(id class_name start_date end_date duration planned_duration scte35_out scte35_in scte35_cmd end_on_next) %}
    it "date range assets {{key.id}} should eq #{expected[:{{key.id}}]?}" do
      item.{{key.id}}.should eq expected[:{{key.id}}]?
    end
  {% end %}

  it "date range assets client_attributes empty?" do 
    item.client_attributes.empty?.should eq expected[:client_attributes].empty?
  end

  expected[:client_attributes].each do |key, value|
    it "date range client_attributes #{key} => #{value}" do
      item.client_attributes[key].should eq value
    end
  end
end

module M3U8
  describe DateRangeItem do
    describe "#new" do
      expected = {
        id: "test_id",
        class_name: "test_class",
        start_date: "2014-03-05T11:15:00Z",
        end_date: "2014-03-05T11:16:00Z",
        duration: 60.1,
        planned_duration: 59.993,
        scte35_out: "0xFC002F0000000000FF0",
        scte35_in: "0xFC002F0000000000FF1",
        scte35_cmd: "0xFC002F0000000000FF2",
        end_on_next: true,
        client_attributes: { "X-CUSTOM" => 45.3 }
      }

      item = DateRangeItem.new(expected)

      date_range_assets(item, expected)
    end

    describe "#parse" do
      describe "all" do
        line = <<-EOF
        #EXT-X-DATERANGE:ID="splice-6FFFFFF0",CLASS="test_class"
        START-DATE="2014-03-05T11:15:00Z",
        END-DATE="2014-03-05T11:16:00Z",DURATION=60.1,
        PLANNED-DURATION=59.993,SCTE35-OUT=0xFC002F0000000000FF0,
        SCTE35-IN=0xFC002F0000000000FF1,
        SCTE35-CMD=0xFC002F0000000000FF2,
        END-ON-NEXT=YES,
        X-CUSTOM=45.3
        EOF

        expected = {
          id: "splice-6FFFFFF0",
          class_name: "test_class",
          start_date: "2014-03-05T11:15:00Z",
          end_date: "2014-03-05T11:16:00Z",
          duration: 60.1,
          planned_duration: 59.993,
          scte35_out: "0xFC002F0000000000FF0",
          scte35_in: "0xFC002F0000000000FF1",
          scte35_cmd: "0xFC002F0000000000FF2",
          end_on_next: true,
          client_attributes: { "X-CUSTOM" => 45.3 }
        }

        item = DateRangeItem.new
        item.parse(line)
        date_range_assets(item, expected)
      end

      describe "ignore" do
        line = <<-EOF
        #EXT-X-DATERANGE:ID="splice-6FFFFFF0",
        START-DATE="2014-03-05T11:15:00Z"
        EOF

        expected = {
          id: "splice-6FFFFFF0",
          start_date: "2014-03-05T11:15:00Z",
          end_on_next: false,
          client_attributes: NamedTuple.new
        }

        item = DateRangeItem.new
        item.parse(line)
        date_range_assets(item, expected)
      end

      it "should parse client-defined attributes" do
        line = <<-EOF
        #EXT-X-DATERANGE:ID="splice-6FFFFFF0",
        START-DATE="2014-03-05T11:15:00Z",
        X-CUSTOM-VALUE="test_value",
        EOF

        expected = {
          id: "splice-6FFFFFF0",
          start_date: "2014-03-05T11:15:00Z",
          end_on_next: false,
          client_attributes: { "X-CUSTOM-VALUE" => "test_value" }
        }

        item = DateRangeItem.new
        item.parse(line)
        date_range_assets(item, expected)
      end
    end

    describe "#to_s" do
      it "should render m3u8 tag" do
        options = {
          id: "test_id",
          class_name: "test_class",
          start_date: "2014-03-05T11:15:00Z",
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
        }
        item = DateRangeItem.new(options)

        expected = <<-EOF
        #EXT-X-DATERANGE:ID="test_id",CLASS="test_class",
        START-DATE="2014-03-05T11:15:00Z",
        END-DATE="2014-03-05T11:16:00Z",DURATION=60.1,
        PLANNED-DURATION=59.993,
        X-CUSTOM=45.3,
        X-CUSTOM-TEXT="test_value",
        SCTE35-CMD=0xFC002F0000000000FF2,
        SCTE35-OUT=0xFC002F0000000000FF0,
        SCTE35-IN=0xFC002F0000000000FF1,
        END-ON-NEXT=YES
        EOF

        item.to_s.should eq expected.delete('\n')
      end

      it "should ignore optional attributes" do
        options = {
          id: "test_id",
          start_date: "2014-03-05T11:15:00Z"
        }
        item = DateRangeItem.new(options)

        expected = <<-EOF
        #EXT-X-DATERANGE:ID="test_id",
        START-DATE="2014-03-05T11:15:00Z"
        EOF

        item.to_s.should eq expected.delete('\n')
      end
    end
  end
end
