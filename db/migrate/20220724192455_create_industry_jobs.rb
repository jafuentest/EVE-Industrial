class CreateIndustryJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :industry_jobs, id: false do |t|
      t.bigint :id, null: false
      t.bigint :character_id
      t.bigint :blueprint_id
      t.bigint :blueprint_type_id
      t.bigint :product_type_id
      t.bigint :activity_id
      t.bigint :station_id
      t.bigint :facility_id
      t.bigint :installer_id

      t.datetime :start_date, precision: 0
      t.datetime :end_date, precision: 0
      t.datetime :pause_date, precision: 0
      t.datetime :completed_date, precision: 0
      t.integer :duration
      t.integer :runs
      t.integer :licensed_runs
      t.integer :successful_runs
      t.decimal :cost, precision: 20, scale: 2
      t.decimal :probability, precision: 5, scale: 4
      t.string :status

      t.index :id, unique: true
    end
  end
end
