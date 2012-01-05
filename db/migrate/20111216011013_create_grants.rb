class CreateGrants < ActiveRecord::Migration
  def change
    create_table :grants do |t|
      t.integer :privilege_id
      t.integer :role_id

      t.timestamps
    end
  end
end
