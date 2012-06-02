class AddIsCollectionToChildMenuItem < ActiveRecord::Migration
  def change
    add_column :child_menu_items, :is_collection, :boolean
  end
end
