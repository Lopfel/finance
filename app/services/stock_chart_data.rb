class StockChartData
  PERIODS = {
    "1m" => 21,
    "3m" => 63,
    "6m" => 126,
    "1y" => 252
  }.freeze

  def initialize(stock, range: "3m")
    @stock = stock
    @range = PERIODS.key?(range) ? range : "3m"
  end

  def call
    prices = Rails.cache.fetch(
      "stock_chart_#{@stock.ticker}_#{@range}",
      expires_in: 15.minutes
    ) do
      FmpClient.fetch_historical_prices(
        @stock.ticker,
        PERIODS[@range]
      )
    end

    candles = normalize_prices(prices || [])

    {
      ticker: @stock.ticker,
      range: @range,
      candles: candles,
      summary: calculate_summary(candles)
    }
  end

  private

  def normalize_prices(prices)
    prices.filter_map do |price|
      next unless price["date"].present?

      open = price["open"]
      high = price["high"]
      low = price["low"]
      close = price["close"]

      next if [ open, high, low, close ].any?(&:nil?)

      {
        time: price["date"],
        open: open.to_f,
        high: high.to_f,
        low: low.to_f,
        close: close.to_f
      }
    end.sort_by { |price| price[:time] }
  end

  def calculate_summary(candles)
    return {} if candles.empty?

    first_close = candles.first[:close]
    last_close = candles.last[:close]

    change = last_close - first_close

    change_percentage =
      if first_close.positive?
        (change / first_close) * 100
      else
        0
      end

    {
      current_price: last_close.round(2),
      previous_price: first_close.round(2),
      change: change.round(2),
      change_percentage: change_percentage.round(2),
      positive: change >= 0,
      highest: candles.map { |c| c[:high] }.max.round(2),
      lowest: candles.map { |c| c[:low] }.min.round(2)
    }
  end
end
