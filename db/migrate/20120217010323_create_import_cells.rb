class CreateImportCells < ActiveRecord::Migration
  def self.up
    create_table :import_cells do |t|
      t.integer :import_table_id
      t.integer :row_index
      t.integer :column_index
      t.string :contents

      t.timestamps
    end
    add_index :import_cells, [:import_table_id]
  end

  def self.down
    drop_table :import_cells
  end
end
