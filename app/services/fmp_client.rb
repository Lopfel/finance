require "net/http"
require "json"

class FmpClient
  BASE_URL = "https://financialmodelingprep.com/api/v3"

  def self.fetch_quote(ticker)
    api_key = Rails.application.credentials.dig(:fmp, :api_key) || ENV["FMP_API_KEY"]
    uri = URI("#{BASE_URL}/quote/#{ticker.upcase}?apikey=#{api_key}")
    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)
    data = JSON.parse(response.body)
    data.first if data.is_a?(Array) && data.any?
  rescue StandardError => e
    nil
  end

  def self.fetch_historical_prices(ticker, limit = 30)
    api_key = Rails.application.credentials.dig(:fmp, :api_key) || ENV["FMP_API_KEY"]
    uri = URI("#{BASE_URL}/historical-price-full/#{ticker.upcase}?limit=#{limit}&apikey=#{api_key}")

    response = Net::HTTP.get_response(uri)
    return [] unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    data["historical"] || []
  rescue StandardError => e
    Rails.logger.error("Error obteniendo histórico para #{ticker}: #{e.message}")
    []
  end
end
