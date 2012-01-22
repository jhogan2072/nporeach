class CreateColumnPreferences < ActiveRecord::Migration
  def change
    create_table :column_preferences do |t|
      t.integer :user_id
      t.string :model_name
      t.string :column_name
      t.integer :column_order

      t.timestamps
    end
  end
end
