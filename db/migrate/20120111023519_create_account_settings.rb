class CreateAccountSettings < ActiveRecord::Migration
  def change
    create_table :account_settings do |t|
      t.integer :account_id
      t.integer :setting_id
      t.string :value

      t.timestamps
    end
  end
end
