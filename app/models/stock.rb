class Stock < ApplicationRecord
  has_many :portfolio_holdings
  has_many :portfolios, through: :portfolio_holdings

  has_many :portfolio_allocations
  has_many :allocated_portfolios, through: :portfolio_allocations, source: :portfolio

  validates :ticker, presence: true, uniqueness: true
  validates :name, presence: true

  def update_current_price!(new_price)
    update!(current_price: new_price)
  end
end
