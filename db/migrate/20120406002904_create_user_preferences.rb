class CreateUserPreferences < ActiveRecord::Migration
  def change
    create_table :user_preferences do |t|
      t.integer :user_id
      t.string :pref_key
      t.string :pref_value
      t.integer :seq_no

      t.timestamps
    end
    add_index "user_preferences", ["user_id"], :name => "ix_user_preferences_user_id"
  end
end
