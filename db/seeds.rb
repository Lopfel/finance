# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


puts "Creating development portfolio..."

# 1. Create user
user = User.find_or_initialize_by(email: "admin@example.com")

if user.new_record?
  user.assign_attributes(
    name: "Kinverly Felix",
    password: "password123",
    password_confirmation: "password123"
  )
  user.save!
end

# 2. Create stocks and update prices from FMP
stocks = [
  { ticker: "AAPL", name: "Apple Inc.", fallback_price: 180.0 },
  { ticker: "META", name: "Meta Platforms Inc.", fallback_price: 450.0 },
  { ticker: "MSFT", name: "Microsoft Corporation", fallback_price: 420.0 }
]

stocks.each do |attributes|
  stock = Stock.find_or_initialize_by(ticker: attributes[:ticker])

  stock.name = attributes[:name]
  stock.current_price ||= attributes[:fallback_price]
  stock.save!

  quote = FmpClient.fetch_quote(stock.ticker)
  api_price = quote&.dig("price")

  if api_price.present? && api_price.to_f.positive?
    stock.update!(current_price: api_price)
    puts "#{stock.ticker}: updated from FMP ($#{api_price})"
  else
    puts "#{stock.ticker}: keeping saved price ($#{stock.current_price})"
  end
end

# 3. Create portfolio
portfolio = Portfolio.find_or_initialize_by(
  user: user,
  name: "Global Tech Alpha Fund"
)

portfolio.save!(validate: false) if portfolio.new_record?

# 4. Create all allocations
allocations = {
  "AAPL" => 35.0,
  "META" => 40.0,
  "MSFT" => 25.0
}

allocations.each do |ticker, percentage|
  stock = Stock.find_by!(ticker: ticker)

  allocation = PortfolioAllocation.find_or_initialize_by(
    portfolio: portfolio,
    stock: stock
  )

  allocation.target_percentage = percentage
  allocation.save!(validate: false)
end

# 5. Create holdings
holdings = {
  "AAPL" => 2,
  "META" => 10,
  "MSFT" => 5
}

holdings.each do |ticker, quantity|
  stock = Stock.find_by!(ticker: ticker)

  holding = PortfolioHolding.find_or_initialize_by(
    portfolio: portfolio,
    stock: stock
  )

  holding.quantity = quantity
  holding.save!
end

# 6. Validate the complete portfolio
portfolio.reload

unless portfolio.valid?
  raise ActiveRecord::RecordInvalid.new(portfolio)
end

puts "Allocations: #{portfolio.portfolio_allocations.sum(:target_percentage)}%"
puts "Holdings: #{portfolio.portfolio_holdings.count}"
puts "Portfolio ID: #{portfolio.id}"
puts "User ID: #{user.id}"
puts "Development portfolio created successfully!"
