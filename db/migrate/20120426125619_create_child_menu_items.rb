class CreateChildMenuItems < ActiveRecord::Migration
  def up
    create_table :child_menu_items do |t|
      t.integer :menu_item_id
      t.string :name
      t.string :help_text
      t.string :controller
      t.string :action

      t.timestamps
    end
  end
  def down
    drop_table :child_menu_items
  end
end
