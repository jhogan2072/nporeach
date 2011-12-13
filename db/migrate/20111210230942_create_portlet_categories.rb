class CreatePortletCategories < ActiveRecord::Migration
  def change
    create_table :portlet_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
