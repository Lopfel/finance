class PortfolioHolding < ApplicationRecord
  belongs_to :portfolio
  belongs_to :stock

  validates :quantity,
            numericality: { greater_than_or_equal_to: 0 }

  validates :stock_id, uniqueness: { scope: :portfolio_id }

  def current_value
    quantity * stock.current_price
  end
end
