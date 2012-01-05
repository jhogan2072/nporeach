class AddAccountIdToRoles < ActiveRecord::Migration
  def up
    add_column :roles, :account_id, :integer
    add_column :privileges, :account_id, :integer
    add_column :privileges, :operations, :integer

    create_table :default_roles do |t|
      t.string :name
      t.timestamps
    end

    create_table :default_grants do |t|
      t.integer :privilege_id
      t.integer :role_id
      t.timestamps
    end

    create_table :default_privileges do |t|
      t.string  :name
      t.string  :description
      t.string  :controller
      t.string  :category
      t.string  :menu_text
      t.integer :operations
      t.timestamps
    end

    remove_column :privileges, :default_action
    remove_column :grants, :operations
 
  end

  def down
    remove_column :roles, :account_id
    remove_column :privileges, :account_id
    remove_column :privileges, :operations
    drop_table :default_roles
    drop_table :default_grants
    drop_table :default_privileges
    add_column :privileges, :default_action, :string
    add_column :grants, :operations, :integer
  end
end
