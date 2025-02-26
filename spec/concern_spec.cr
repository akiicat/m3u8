require "./spec_helper"

module M3U8
  include Concern

  describe Concern do
    describe "parse_attributes" do
      {
        {
          "Key=Value",
          {
            "Key" => "Value",
          },
        },
        {
          "Key=\"Quoted Value\"",
          {
            "Key" => "Quoted Value",
          },
        },
        {
          "Key1=,Key2,=Value",
          {
            "Key1" => "",
          },
        },
      }.each do |(format, params)|
        attributes = parse_attributes(format)

        it "hash result" do
          attributes.should eq params
        end
      end
    end

    describe "parse_client_attributes" do
      {
        {
          {
            "X-CUSTOM" => "Client Attributes",
            "CUSTOM"   => "Not Client Attributes",
          },
          {
            "X-CUSTOM" => "Client Attributes",
          },
        },
      }.each do |(options, params)|
        attributes = parse_client_attributes(options)

        it "hash result" do
          attributes.should eq params
        end
      end
    end

    describe "parse_token" do
      {
        {
          "42",
          42,
        },
        {
          "42.3",
          42.3,
        },
        {
          "true",
          true,
        },
        {
          "false",
          false,
        },
        {
          "",
          "",
        },
        {
          "test",
          "test",
        },
      }.each do |(format, params)|
        token = parse_token(format)

        it "token result" do
          token.should eq params
        end
      end
    end

    describe "parse_resolution" do
      {
        {
          "1280x720",
          {
            width:  1280,
            height: 720,
          },
        },
        {
          "1280.0x720.0",
          {
            width:  1280,
            height: 720,
          },
        },
        {
          "1280",
          {
            width:  1280,
            height: nil,
          },
        },
        {
          "axb",
          {
            width:  nil,
            height: nil,
          },
        },
        {
          "ab",
          {
            width:  nil,
            height: nil,
          },
        },
        {
          "",
          {
            width:  nil,
            height: nil,
          },
        },
        {
          nil,
          {
            width:  nil,
            height: nil,
          },
        },
      }.each do |(format, params)|
        resolution = parse_resolution(format)

        it "width" do
          resolution[:width].should eq params[:width]?
        end

        it "height" do
          resolution[:height].should eq params[:height]?
        end
      end
    end

    describe "parse_frame_rate" do
      {
        {
          "29.97",
          BigDecimal.new(29.97),
        },
        {
          "0",
          nil,
        },
        {
          nil,
          nil,
        },
      }.each do |(format, params)|
        frame_rate = parse_frame_rate(format)

        it "frame_rate result" do
          frame_rate.should eq params
        end
      end
    end

    describe "parse_yes_no" do
      {
        {
          true,
          "YES",
        },
        {
          false,
          "NO",
        },
        {
          nil,
          nil,
        },
      }.each do |(format, params)|
        yes_no = parse_yes_no(format)

        it "yes_no result" do
          yes_no.should eq params
        end
      end
    end

    describe "parse_boolean" do
      {
        {
          "true",
          true,
        },
        {
          "YES",
          true,
        },
        {
          "True",
          true,
        },
        {
          "false",
          false,
        },
        {
          "No",
          false,
        },
        {
          "maybe",
          nil,
        },
        {
          nil,
          nil,
        },
      }.each do |(format, params)|
        boolean = parse_boolean(format)

        it "boolean result" do
          boolean.should eq params
        end
      end
    end
  end
end
