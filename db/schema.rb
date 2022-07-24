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

ActiveRecord::Schema[7.0].define(version: 2022_07_24_192847) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "characters", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "esi_refresh_token"
    t.string "esi_auth_token"
    t.datetime "esi_expires_on", precision: nil
    t.bigint "character_id"
    t.string "character_name"
    t.string "character_portrait"
    t.string "scopes"
    t.string "token_type"
    t.string "owner_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "constellations", id: false, force: :cascade do |t|
    t.bigint "id", null: false
    t.bigint "region_id", null: false
    t.string "name", null: false
    t.index ["id"], name: "index_constellations_on_id", unique: true
    t.index ["region_id"], name: "index_constellations_on_region_id"
  end

  create_table "industry_jobs", id: false, force: :cascade do |t|
    t.bigint "id", null: false
    t.bigint "character_id"
    t.bigint "blueprint_id"
    t.bigint "blueprint_type_id"
    t.bigint "product_type_id"
    t.bigint "activity_id"
    t.bigint "station_id"
    t.bigint "installer_id"
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.integer "runs"
    t.integer "licensed_runs"
    t.decimal "probability", precision: 5, scale: 4
    t.string "status"
    t.index ["id"], name: "index_industry_jobs_on_id", unique: true
  end

  create_table "items", id: false, force: :cascade do |t|
    t.bigint "id", null: false
    t.string "name"
    t.index ["id"], name: "index_items_on_id", unique: true
  end

  create_table "items_prices", id: false, force: :cascade do |t|
    t.bigint "star_id", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.decimal "buy_price", precision: 12, scale: 2
    t.decimal "sell_price", precision: 12, scale: 2
    t.index ["item_id", "star_id"], name: "index_items_prices_on_item_id_and_star_id"
    t.index ["item_id"], name: "index_items_prices_on_item_id"
    t.index ["star_id"], name: "index_items_prices_on_star_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "item_id", null: false
    t.bigint "region_id", null: false
    t.bigint "esi_id"
    t.bigint "location_id"
    t.decimal "price", precision: 12, scale: 2
    t.boolean "buy_order"
    t.integer "duration"
    t.integer "volume_remain"
    t.integer "volume_total"
    t.datetime "issued", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_orders_on_character_id"
    t.index ["item_id"], name: "index_orders_on_item_id"
    t.index ["region_id"], name: "index_orders_on_region_id"
  end

  create_table "planetary_colonies", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "star_id", null: false
    t.bigint "planet_id", null: false
    t.string "planet_type", null: false
    t.integer "upgrade_level", null: false
    t.string "extractors", default: "{}"
    t.string "factories", default: "{}"
    t.datetime "last_update", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_planetary_colonies_on_character_id"
    t.index ["star_id"], name: "index_planetary_colonies_on_star_id"
  end

  create_table "planetary_commodities", id: false, force: :cascade do |t|
    t.bigint "id", null: false
    t.bigint "schematic_id"
    t.string "name", null: false
    t.integer "tier", null: false
    t.decimal "volume", precision: 5, scale: 2
    t.integer "batch_size", null: false
    t.text "input"
    t.index ["id"], name: "index_planetary_commodities_on_id", unique: true
  end

  create_table "regions", id: false, force: :cascade do |t|
    t.bigint "id", null: false
    t.string "name", null: false
    t.index ["id"], name: "index_regions_on_id", unique: true
  end

  create_table "stars", id: false, force: :cascade do |t|
    t.bigint "id", null: false
    t.string "name", null: false
    t.bigint "constellation_id", null: false
    t.bigint "region_id", null: false
    t.index ["constellation_id"], name: "index_stars_on_constellation_id"
    t.index ["id"], name: "index_stars_on_id", unique: true
    t.index ["region_id"], name: "index_stars_on_region_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "esi_refresh_token"
    t.string "esi_auth_token"
    t.datetime "esi_expires_on", precision: nil
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
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.string "remember_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["esi_refresh_token"], name: "index_users_on_esi_refresh_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "characters", "users"
  add_foreign_key "constellations", "regions"
  add_foreign_key "items_prices", "items"
  add_foreign_key "items_prices", "stars"
  add_foreign_key "orders", "characters"
  add_foreign_key "orders", "items"
  add_foreign_key "orders", "regions"
  add_foreign_key "planetary_colonies", "characters"
  add_foreign_key "planetary_colonies", "stars"
  add_foreign_key "stars", "constellations"
  add_foreign_key "stars", "regions"
end
