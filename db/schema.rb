# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_29_004724) do

  create_table "items_prices", id: false, force: :cascade do |t|
    t.integer "star_id", null: false
    t.integer "item_id", null: false
    t.string "item_type", null: false
    t.decimal "buy_price", precision: 12, scale: 2
    t.decimal "sell_price", precision: 12, scale: 2
    t.index ["item_id", "star_id"], name: "index_items_prices_on_item_id_and_star_id"
    t.index ["item_id"], name: "index_items_prices_on_item_id"
    t.index ["star_id"], name: "index_items_prices_on_star_id"
  end

  create_table "planetary_commodities", id: false, force: :cascade do |t|
    t.integer "id", null: false
    t.string "name", null: false
    t.integer "tier", null: false
    t.decimal "volume", precision: 5, scale: 2
    t.integer "batch_size", null: false
    t.text "input"
    t.index ["id"], name: "index_planetary_commodities_on_id", unique: true
  end

  create_table "stars", id: false, force: :cascade do |t|
    t.integer "id", null: false
    t.string "name", null: false
    t.integer "constellation_id", null: false
    t.integer "region_id", null: false
    t.index ["id"], name: "index_stars_on_id", unique: true
  end

  add_foreign_key "items_prices", "stars"
end
