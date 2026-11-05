require 'rails_helper'

RSpec.describe FmpClient do
  let(:valid_api_key) { "test_fmp_api_key" }

  before do
    allow(FmpClient).to receive(:api_key).and_return(valid_api_key)
  end

  describe '.api_key' do
    before { allow(FmpClient).to receive(:api_key).and_call_original }

    it 'fetches API key from Rails credentials or ENV' do
      allow(Rails.application.credentials).to receive(:dig).with(:fmp, :api_key).and_return("cred_key")
      expect(FmpClient.api_key).to eq("cred_key")
    end
  end

  describe '.fetch_historical_prices' do
    let(:http_double) { instance_double(Net::HTTP) }

    let(:success_response) do
      res = Net::HTTPOK.new("1.1", "200", "OK")
      allow(res).to receive(:body).and_return('[{"date": "2026-01-01", "close": 150}]')
      res
    end

    context 'when API key is blank' do
      before { allow(FmpClient).to receive(:api_key).and_return(nil) }

      it 'logs an error and returns an empty array' do
        expect(Rails.logger).to receive(:error).with("[FMP] API key is missing")
        expect(FmpClient.fetch_historical_prices("AAPL")).to eq([])
      end
    end

    context 'when the API call is successful' do
      it 'returns the historical prices array limited by argument' do
        expect(Net::HTTP).to receive(:start).and_yield(http_double)
        expect(http_double).to receive(:get).and_return(success_response)

        result = FmpClient.fetch_historical_prices("AAPL", 5)
        expect(result).to eq([ { "date" => "2026-01-01", "close" => 150 } ])
      end
    end

    context 'when the API returns a non-success HTTP status' do
      let(:error_response) do
        res = Net::HTTPInternalServerError.new("1.1", "500", "Internal Server Error")
        allow(res).to receive(:body).and_return("Server Error")
        res
      end

      it 'logs an error and returns an empty array' do
        expect(Net::HTTP).to receive(:start).and_yield(http_double)
        expect(http_double).to receive(:get).and_return(error_response)
        expect(Rails.logger).to receive(:error).with(start_with("[FMP] HTTP 500"))

        expect(FmpClient.fetch_historical_prices("AAPL")).to eq([])
      end
    end

    context 'when response body is not an array' do
      let(:not_an_array_response) do
        res = Net::HTTPOK.new("1.1", "200", "OK")
        allow(res).to receive(:body).and_return('{"error": "invalid"}')
        res
      end

      it 'logs an error and returns an empty array' do
        expect(Net::HTTP).to receive(:start).and_yield(http_double)
        expect(http_double).to receive(:get).and_return(not_an_array_response)
        expect(Rails.logger).to receive(:error).with(start_with("[FMP] Unexpected response"))

        expect(FmpClient.fetch_historical_prices("AAPL")).to eq([])
      end
    end

    context 'when a StandardError is raised' do
      it 'rescues the error, logs it, and returns an empty array' do
        expect(Net::HTTP).to receive(:start).and_raise(StandardError.new("Network timeout"))
        expect(Rails.logger).to receive(:error).with(start_with("[FmpClient] Historical error:"))

        expect(FmpClient.fetch_historical_prices("AAPL")).to eq([])
      end
    end
  end

  describe '.fetch_quote' do
    let(:http_double) { instance_double(Net::HTTP) }

    let(:success_response) do
      res = Net::HTTPOK.new("1.1", "200", "OK")
      allow(res).to receive(:body).and_return('[{"symbol": "AAPL", "price": 175.5}]')
      res
    end

    context 'when API key is blank' do
      before { allow(FmpClient).to receive(:api_key).and_return(nil) }

      it 'returns nil without making a request' do
        expect(Net::HTTP).not_to receive(:start)
        expect(FmpClient.fetch_quote("AAPL")).to be_nil
      end
    end

    context 'when the API call is successful' do
      it 'returns the first element of the quote array' do
        expect(Net::HTTP).to receive(:start).and_yield(http_double)
        expect(http_double).to receive(:get).and_return(success_response)

        result = FmpClient.fetch_quote("AAPL")
        expect(result).to eq({ "symbol" => "AAPL", "price" => 175.5 })
      end
    end

    context 'when the API returns a non-success HTTP status' do
      let(:error_response) do
        res = Net::HTTPNotFound.new("1.1", "404", "Not Found")
        allow(res).to receive(:body).and_return("Not Found")
        res
      end

      it 'logs an error and returns nil' do
        expect(Net::HTTP).to receive(:start).and_yield(http_double)
        expect(http_double).to receive(:get).and_return(error_response)
        expect(Rails.logger).to receive(:error).with(start_with("[FMP] Quote HTTP 404"))

        expect(FmpClient.fetch_quote("AAPL")).to be_nil
      end
    end

    context 'when a StandardError is raised' do
      it 'rescues the error, logs it, and returns nil' do
        expect(Net::HTTP).to receive(:start).and_raise(StandardError.new("Connection refused"))
        expect(Rails.logger).to receive(:error).with(start_with("[FmpClient] Quote error:"))

        expect(FmpClient.fetch_quote("AAPL")).to be_nil
      end
    end
  end
end
