# typed: strict
# frozen_string_literal: true

require "download_strategy"

# Downloads Feiniu assets through the vendor's short-lived URL signing service.
class FnSignedDownloadStrategy < CurlDownloadStrategy
  SIGN_ENDPOINT = "https://fnnas.com/asset/download-sign"

  private

  sig { override.params(url: String, timeout: T.nilable(T.any(Float, Integer))).returns(URLMetadata) }
  def resolve_url_basename_time_file_size(url, timeout: nil)
    super(signed_url(url), timeout: timeout)
  end

  sig { params(url: String).returns(String) }
  def signed_url(url)
    @signed_urls ||= {}
    @signed_urls[url] ||= begin
      response = curl_output(
        "--fail",
        "--silent",
        "--show-error",
        "--request", "POST",
        "--header", "Content-Type: application/json",
        "--data", JSON.generate(url: url),
        SIGN_ENDPOINT
      )
      signed = URI(JSON.parse(response.stdout).fetch("url"))
      original = URI(url)

      if signed.scheme != "https" || signed.host != original.host || signed.path != original.path
        raise CurlDownloadStrategyError.new(url, "Feiniu returned an unexpected signed download URL.")
      end

      signed.to_s
    end
  rescue ErrorDuringExecution, JSON::ParserError, KeyError, URI::InvalidURIError => e
    raise CurlDownloadStrategyError.new(url, "Unable to obtain a signed Feiniu download URL: #{e.message}")
  end
end
