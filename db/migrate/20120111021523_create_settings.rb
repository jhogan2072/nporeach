class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :name
      t.string :description
      t.string :default_value

      t.timestamps
    end
  end
end
