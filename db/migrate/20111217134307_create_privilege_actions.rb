class CreatePrivelegeActions < ActiveRecord::Migration
  def change
    create_table :privilege_actions do |t|
      t.integer :privilege_id
      t.string :action

      t.timestamps
    end
  end
end
