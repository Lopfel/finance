require "net/http"
require "json"

class FmpClient
  STABLE_URL = "https://financialmodelingprep.com/stable"

  def self.api_key
    Rails.application.credentials.dig(:fmp, :api_key) ||
      ENV["FMP_API_KEY"]
  end

  def self.fetch_historical_prices(ticker, limit = 90)
    key = api_key

    if key.blank?
      Rails.logger.error("[FMP] API key is missing")
      return []
    end

    to = Date.current
    from = to - (limit * 2).days

    uri = URI("#{STABLE_URL}/historical-price-eod/full")

    uri.query = URI.encode_www_form(
      symbol: ticker.upcase,
      from: from.to_s,
      to: to.to_s,
      apikey: key
    )

    response = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: true,
      open_timeout: 5,
      read_timeout: 15
    ) do |http|
      http.get(uri.request_uri)
    end

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error(
        "[FMP] HTTP #{response.code}: #{response.body.to_s.truncate(500)}"
      )
      return []
    end

    data = JSON.parse(response.body)

    unless data.is_a?(Array)
      Rails.logger.error(
        "[FMP] Unexpected response: #{data.inspect.truncate(500)}"
      )
      return []
    end

    data.first(limit)
  rescue StandardError => e
    Rails.logger.error("[FmpClient] Historical error: #{e.class} - #{e.message}")
    []
  end

  def self.fetch_quote(ticker)
    key = api_key
    return nil if key.blank?

    uri = URI("#{STABLE_URL}/quote")

    uri.query = URI.encode_www_form(
      symbol: ticker.upcase,
      apikey: key
    )

    response = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: true,
      open_timeout: 5,
      read_timeout: 15
    ) do |http|
      http.get(uri.request_uri)
    end

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("[FMP] Quote HTTP #{response.code}: #{response.body.to_s.truncate(500)}")
      return nil
    end

    data = JSON.parse(response.body)
    data.is_a?(Array) ? data.first : nil
  rescue StandardError => e
    Rails.logger.error("[FmpClient] Quote error: #{e.class} - #{e.message}")
    nil
  end
end
