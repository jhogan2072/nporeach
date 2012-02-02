class CreateColumnPreferences < ActiveRecord::Migration
  def change
    create_table :column_preferences do |t|
      t.integer :user_id
      t.string :collection_name
      t.string :column_name
      t.boolean :is_displayed
      t.integer :column_order

      t.timestamps
    end
  end
end
