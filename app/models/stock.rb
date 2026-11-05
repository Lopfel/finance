class Stock < ApplicationRecord
  has_many :portfolio_holdings
  has_many :portfolios, through: :portfolio_holdings

  has_many :portfolio_allocations
  has_many :allocated_portfolios, through: :portfolio_allocations, source: :portfolio

  validates :ticker, presence: true, uniqueness: true
  validates :name, presence: true

  def fetch_current_price
    cached_price = Rails.cache.fetch("stock_price_#{ticker}", expires_in: 10.minutes) do
      quote_data = FmpClient.fetch_quote(ticker)
      quote_data ? quote_data["price"] : nil
    end

    if cached_price
      update_column(:current_price, cached_price) if current_price != cached_price
      cached_price
    else
      current_price
    end
  end
end
