require "./spec_helper"

module M3U8
  describe ByteRange do
    describe "initialize" do
      {
        {
          { length: 4500, start: 600 },
          "4500@600"
        },
        {
          { length: 4000, start: nil },
          "4000"
        },
        {
          { length: 3300 },
          "3300"
        },
      }.each do |(params, format)|
        item = ByteRange.new(params)

        describe "initialize" do
          it "length" do
            item.length.should eq params[:length]
          end

          it "start" do
            item.start.should eq params[:start]?
          end
        end

        it "to_s" do
          item.to_s.should eq format
        end
      end

      # describe "parse" do
      #   {
      #     {"3500@300", {length: 3500, start: 300}},
      #     {"4000", {length: 4000}},
      #   }.each do |(input, output)|
      #     it "#{input}" do
      #       range = M3U8::ByteRange.parse(input)
      #       range.length.should eq output[:length]
      #       range.start.should eq output[:start]?
      #     end
      #   end
      # end
    end
  end
end
