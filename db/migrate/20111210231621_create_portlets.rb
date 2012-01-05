class CreatePortlets < ActiveRecord::Migration
  def change
    create_table :portlets do |t|
      t.string :name
      t.integer :category_id
      t.string :portlet_url

      t.timestamps
    end
  end
end
