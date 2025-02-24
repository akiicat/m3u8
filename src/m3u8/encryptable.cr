module M3U8
  # Provides common functionality for constructing encryption key tags in HTTP Live Streaming (HLS).
  #
  # According to [RFC 8216, Section 4.3.2.4](https://datatracker.ietf.org/doc/html/rfc8216#section-4.3.2.4), the
  # `EXT-X-KEY` tag specifies the encryption parameters for Media Segments in an HLS playlist.
  # This tag includes several attributes:
  #
  # ```txt
  # #EXT-X-KEY:METHOD=AES-128,URI="http://test.key",IV=D512BBF,KEYFORMAT="identity",KEYFORMATVERSIONS="1/3"
  # ```
  #
  # - ***METHOD*** (required): Specifies the encryption method (e.g. NONE, AES-128, SAMPLE-AES).
  # - ***URI*** (optional): The *URI* used to fetch the decryption key (optional if *METHOD* is NONE; required otherwise).
  # - ***IV*** (optional): The Initialization Vector, expressed as a hexadecimal sequence.
  # - ***KEYFORMAT*** (optional): A string that indicates the key format (defaults to "identity" if omitted).
  # - ***KEYFORMATVERSIONS*** (optional): Indicates the supported key format versions (defaults to 1 if omitted).
  #
  # This module provides helper methods that convert parameter hashes into the correctly formatted
  # attribute string for inclusion in an `EXT-X-KEY` tag.
  module Encryptable

    # The value is a string that specifies the encryption method.
    #
    # The methods defined are: `NONE`, `AES-128`, and `SAMPLE-AES`.
    # An encryption method of `NONE` means that Media Segments are not encrypted.
    property method : String

    # The value is a string containing a *URI* that specifies how
    # to obtain the key.
    property uri : String?

    # The value is a hexadecimal-sequence that specifies a 128-bit
    # unsigned integer Initialization Vector *IV* to be used with the key.
    property iv : String?

    # The value is a string that specifies how the key is
    # represented in the resource identified by the *URI*;
    property key_format : String?

    # The value is a string containing one or more positive
    # integers separated by the `/` character (for example, `1`, `1/2`, or `1/2/5`).
    property key_format_versions : String?

    # Converts a hash of parameters (with keys in uppercase, as in a playlist) into
    # a new hash with symbolized keys for internal use.
    #
    # Expected keys are:
    # - `METHOD`
    # - `URI`
    # - `IV`
    # - `KEYFORMAT`
    # - `KEYFORMATVERSIONS`.
    #
    # Returns a NamedTuple.
    #
    # Example:
    #
    # ```crystal
    # options = {
    #   "METHOD"            => "AES-128",
    #   "URI"               => "http://test.key",
    #   "IV"                => "D512BBF",
    #   "KEYFORMAT"         => "identity",
    #   "KEYFORMATVERSIONS" => "1/3",
    # }
    # Encryptable.convert_key(options)
    # # => {method: "AES-128",
    # #     uri: "http://test.key",
    # #     iv: "D512BBF",
    # #     key_format: "identity",
    # #     key_format_versions: "1/3"}
    # ```
    def self.convert_key(params)
      {
        method:              params["METHOD"],
        uri:                 params["URI"]?,
        iv:                  params["IV"]?,
        key_format:          params["KEYFORMAT"]?,
        key_format_versions: params["KEYFORMATVERSIONS"]?,
      }
    end

    # Alternative constructor that accepts a NamedTuple with symbol keys.
    #
    # Example:
    #
    # ```crystal
    # options = {
    #   method: "AES-128",
    #   uri: "https://example.com/key",
    #   iv: "0x1a2b3c",
    #   key_format: "identity",
    #   key_format_versions: "1"
    # }
    # class Something
    #   include Encryptable
    # end
    # Something.new(options)
    # # => #<App::Something:0x78b71f3a9380
    # #     @iv="0x1a2b3c",
    # #     @key_format="identity",
    # #     @key_format_versions="1",
    # #     @method="AES-128",
    # #     @uri="https://example.com/key">
    # ```
    def self.new(params : NamedTuple = NamedTuple.new)
      new(
        method: params[:method],
        uri: params[:uri]?,
        iv: params[:iv]?,
        key_format: params[:key_format]?,
        key_format_versions: params[:key_format_versions]?
      )
    end

    # Initializes a new `Encryptable` instance with the given parameters.
    #
    # Parameters:
    #   - `method`: The encryption method (required).
    #   - `uri`: The *URI* for the key (optional).
    #   - `iv`: The Initialization Vector *IV* (optional).
    #   - `key_format`: The key format (optional).
    #   - `key_format_versions`: The supported key format versions (optional).
    #
    # ```crystal
    # class Something
    #   include Encryptable
    # end
    # Something.new(method: "AES-128", uri: "https://example.com/key")
    # # => #<App::Something:0x7cae3cdbb2c0
    # #     @iv=nil,
    # #     @key_format=nil,
    # #     @key_format_versions=nil,
    # #     @method="AES-128",
    # #     @uri="https://example.com/key">
    # ```
    def initialize(@method = "",
                   @uri = nil,
                   @iv = nil,
                   @key_format = nil,
                   @key_format_versions = nil)
    end

    # Constructs a string representation of the encryption key attributes.
    #
    # The output is a comma-separated list of attribute assignments,
    # suitable for inclusion in an `EXT-X-KEY` tag.
    #
    # Example:
    #
    # ```crystal
    # class Something
    #   include Encryptable
    # end
    # Something.new(method: "AES-128", uri: "https://example.com/key").attributes_to_s
    # # => "METHOD=AES-128,URI=\"https://example.com/key\""
    # ```
    def attributes_to_s
      attributes.join(',')
    end

    private def attributes
      [
        method_format,
        uri_format,
        iv_format,
        key_format_format,
        key_format_versions_format,
      ].compact
    end

    private def method_format
      "METHOD=#{method}"
    end

    private def uri_format
      %(URI="#{uri}") unless uri.nil?
    end

    private def iv_format
      "IV=#{iv}" unless iv.nil?
    end

    private def key_format_format
      %(KEYFORMAT="#{key_format}") unless key_format.nil?
    end

    private def key_format_versions_format
      %(KEYFORMATVERSIONS="#{key_format_versions}") unless key_format_versions.nil?
    end
  end
end
