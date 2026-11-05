class CreateStocks < ActiveRecord::Migration[8.1]
  def change
    create_table :stocks do |t|
      t.string :ticker, null: false, index: { unique: true }
      t.string :name, null: false
      t.decimal :current_price, precision: 12, scale: 4, null: false, default: 0.0

      t.timestamps
    end
  end
end
