# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140301064642) do

  create_table "ice_ores", :force => true do |t|
    t.string  "name"
    t.float   "volume"
    t.integer "central_id"
  end

  create_table "ice_products", :force => true do |t|
    t.string  "name"
    t.float   "volume"
    t.integer "central_id"
  end

  create_table "ice_yields", :force => true do |t|
    t.integer "quantity"
    t.integer "ice_ore_id"
    t.integer "ice_product_id"
  end

  create_table "minerals", :force => true do |t|
    t.string  "name"
    t.string  "volume"
    t.integer "central_id"
  end

  create_table "ores", :force => true do |t|
    t.string  "name"
    t.integer "refine"
    t.float   "volume"
  end

  create_table "planetary_commodities", :force => true do |t|
    t.string  "name"
    t.float   "volume"
    t.integer "quantity"
    t.integer "tier"
    t.integer "central_id"
  end

  create_table "regions", :force => true do |t|
    t.string  "name"
    t.integer "central_id"
  end

  create_table "schematics", :force => true do |t|
    t.integer "output_id"
    t.integer "input_id"
    t.integer "quantity"
  end

  create_table "systems", :force => true do |t|
    t.string  "name"
    t.integer "central_id"
    t.integer "region_id"
    t.float   "security"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "password"
    t.boolean  "is_admin"
    t.datetime "last_login"
    t.datetime "created_at"
  end

  create_table "variations", :force => true do |t|
    t.string  "name"
    t.integer "ore_id"
    t.integer "bonus"
    t.integer "central_id"
  end

  create_table "yields", :force => true do |t|
    t.integer "quantity"
    t.integer "variation_id"
    t.integer "mineral_id"
  end

end
