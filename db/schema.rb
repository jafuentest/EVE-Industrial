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

ActiveRecord::Schema.define(version: 2020_12_11_043821) do

  create_table "items", id: false, force: :cascade do |t|
    t.integer "id", null: false
    t.string "name"
    t.index ["id"], name: "index_items_on_id", unique: true
  end

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

  create_table "orders", force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "esi_id"
    t.integer "location_id"
    t.integer "character_id"
    t.decimal "price"
    t.datetime "issued"
    t.integer "duration"
    t.boolean "buy_order"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_orders_on_item_id"
  end

  create_table "planetary_commodities", id: false, force: :cascade do |t|
    t.integer "id", null: false
    t.integer "schematic_id"
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

  create_table "users", force: :cascade do |t|
    t.string "esi_refresh_token"
    t.string "esi_auth_token"
    t.datetime "esi_expires_on"
    t.bigint "character_id"
    t.string "character_name"
    t.string "character_portrait"
    t.string "scopes"
    t.string "token_type"
    t.string "owner_hash"
    t.string "role"
    t.string "email"
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["esi_refresh_token"], name: "index_users_on_esi_refresh_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "items_prices", "stars"
  add_foreign_key "orders", "items"
end
