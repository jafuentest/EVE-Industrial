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

ActiveRecord::Schema.define(:version => 20140203180644) do

  create_table "minerals", :force => true do |t|
    t.string "name"
    t.string "volume"
  end

  create_table "ores", :force => true do |t|
    t.string  "name"
    t.integer "refine"
    t.float   "volume"
  end

  create_table "variations", :force => true do |t|
    t.string  "name"
    t.integer "ore_id"
  end

  create_table "yields", :force => true do |t|
    t.integer "quantity"
    t.integer "bonus"
    t.integer "variation_id"
    t.integer "mineral_id"
  end

end
