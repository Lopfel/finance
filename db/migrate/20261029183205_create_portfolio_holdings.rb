class CreatePortfolioHoldings < ActiveRecord::Migration[8.1]
  def change
    create_table :portfolio_holdings do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.decimal :quantity, precision: 15, scale: 6, null: false, default: 0.0

      t.timestamps
    end

    add_index :portfolio_holdings, [ :portfolio_id, :stock_id ], unique: true
  end
end
