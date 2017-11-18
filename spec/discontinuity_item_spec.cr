require "./spec_helper"

module M3U8
  describe DiscontinuityItem do
    it "should provide m3u8 format representation" do
      item = DiscontinuityItem.new
      item.to_s.should eq "#EXT-X-DISCONTINUITY\n"
    end
  end
end
