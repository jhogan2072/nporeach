class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :home_phone
      t.string :work_phone
      t.string :mobile_phone
      t.string :email
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token, :null => false
      t.datetime :last_login_at
      t.datetime :current_login_at
      t.string :last_login_ip
      t.string :current_login_ip
      t.string :single_access_token
      t.integer :account_id
      t.integer :customer_id
      t.boolean :admin, :default => false

      t.timestamps
    end

    add_index :users, :email
    add_index :users, :persistence_token
    add_index :users, :single_access_token, :unique => true
    add_index :users, :account_id

  end
end
