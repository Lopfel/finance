class CreatePortfolioAllocations < ActiveRecord::Migration[8.1]
  def change
    create_table :portfolio_allocations do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.decimal :target_percentage, precision: 5, scale: 2, null: false

      t.timestamps
    end

    add_index :portfolio_allocations, [ :portfolio_id, :stock_id ], unique: true
  end
end
