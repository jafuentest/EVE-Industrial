class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login
      t.string :password
      t.boolean :is_admin
      t.timestamp :last_login
      t.timestamp :created_at
    end
      
    User.create :login => 'admin', :password => 'admin', :is_admin => true
  end
end
