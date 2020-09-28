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

ActiveRecord::Schema.define(version: 2020_09_27_060147) do

  create_table "planetary_commodities", id: false, force: :cascade do |t|
    t.integer "id", null: false
    t.string "name"
    t.integer "tier"
    t.decimal "volume", precision: 5, scale: 2
    t.integer "batch_size"
    t.text "input"
    t.index ["id"], name: "index_planetary_commodities_on_id", unique: true
  end

end
