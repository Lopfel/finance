class Portfolio < ApplicationRecord
  belongs_to :user

  has_many :portfolio_holdings, dependent: :destroy
  has_many :stocks, through: :portfolio_holdings

  has_many :portfolio_allocations, dependent: :destroy
  has_many :target_stocks, through: :portfolio_allocations, source: :stock

  validate :validate_total_allocation_percentage

  validate :validate_total_allocation_percentage

  def total_value
    portfolio_holdings.joins(:stock).sum("portfolio_holdings.quantity * stocks.current_price")
  end

  private

  def validate_total_allocation_percentage
    total = portfolio_allocations.sum(:target_percentage)
    unless total == 100.0
      errors.add(:base, "La suma de los porcentajes de asignación debe ser 100% (actual: #{total}%)")
    end
  end
end
