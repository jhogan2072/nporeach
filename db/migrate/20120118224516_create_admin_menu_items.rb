class CreateAdminMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
      t.string :name
      t.string :help_text
      t.string :category
      t.string :controller
      t.string :action

      t.timestamps
    end
  end
end
