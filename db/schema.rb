# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_29_183427) do
  create_table "portfolio_allocations", force: :cascade do |t|
    t.integer "portfolio_id", null: false
    t.integer "stock_id", null: false
    t.decimal "target_percentage", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_id", "stock_id"], name: "index_portfolio_allocations_on_portfolio_id_and_stock_id", unique: true
    t.index ["portfolio_id"], name: "index_portfolio_allocations_on_portfolio_id"
    t.index ["stock_id"], name: "index_portfolio_allocations_on_stock_id"
  end

  create_table "portfolio_holdings", force: :cascade do |t|
    t.integer "portfolio_id", null: false
    t.integer "stock_id", null: false
    t.decimal "quantity", precision: 15, scale: 6, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["portfolio_id", "stock_id"], name: "index_portfolio_holdings_on_portfolio_id_and_stock_id", unique: true
    t.index ["portfolio_id"], name: "index_portfolio_holdings_on_portfolio_id"
    t.index ["stock_id"], name: "index_portfolio_holdings_on_stock_id"
  end

  create_table "portfolios", force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "ticker", null: false
    t.string "name", null: false
    t.decimal "current_price", precision: 12, scale: 4, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticker"], name: "index_stocks_on_ticker", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "portfolio_allocations", "portfolios"
  add_foreign_key "portfolio_allocations", "stocks"
  add_foreign_key "portfolio_holdings", "portfolios"
  add_foreign_key "portfolio_holdings", "stocks"
  add_foreign_key "portfolios", "users"
end
