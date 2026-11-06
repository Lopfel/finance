class Portfolio < ApplicationRecord
  belongs_to :user

  has_many :portfolio_holdings, dependent: :destroy
  has_many :stocks, through: :portfolio_holdings

  has_many :portfolio_allocations, dependent: :destroy
  has_many :target_stocks, through: :portfolio_allocations, source: :stock

  accepts_nested_attributes_for :portfolio_allocations, allow_destroy: true

  validate :validate_total_allocation_percentage

  def total_value
    portfolio_holdings.joins(:stock).sum("portfolio_holdings.quantity * stocks.current_price")
  end

  private

  def validate_total_allocation_percentage
    total = portfolio_allocations.to_a.sum do |allocation|
      allocation.target_percentage.to_d
    end

    unless (total - 100).abs < 0.0001
      errors.add(
        :base,
        "Total allocation must equal 100% (current: #{total}%)"
      )
    end
  end

  def set_portfolio
    @portfolio = Portfolio.find(params[:id])
  end
end
