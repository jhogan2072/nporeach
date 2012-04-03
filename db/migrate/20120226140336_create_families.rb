class CreateFamilies < ActiveRecord::Migration
  def change
    create_table :families do |t|
      t.string :name
      t.integer :account_id
      t.boolean :is_individual

      t.timestamps
    end
  end
end
