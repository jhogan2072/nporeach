class CreatePrivileges < ActiveRecord::Migration
  def change
    create_table :privileges do |t|
      t.string :name
      t.string :description
      t.string :controller
      t.string :action
      t.integer :menu_item_id

      t.timestamps
    end
  end
end
