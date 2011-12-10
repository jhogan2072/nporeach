class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name, :null => false 
      t.text :description
      t.string :full_domain, :null => false
      t.string :logo_url
      t.datetime :deleted_at

      t.timestamps
    end

    add_index "accounts", "full_domain"

  end
end
