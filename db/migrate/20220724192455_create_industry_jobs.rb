class CreateIndustryJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :industry_jobs, id: false do |t|
      t.bigint :id, null: false
      t.bigint :character_id
      t.bigint :blueprint_id
      t.bigint :blueprint_type_id
      t.bigint :product_type_id
      t.bigint :activity_id
      t.bigint :station_id
      t.bigint :installer_id

      t.datetime :start_date
      t.datetime :end_date
      t.integer :runs
      t.integer :licensed_runs
      t.decimal :probability, precision: 5, scale: 4
      t.string :status

      t.index :id, unique: true
    end
  end
end
