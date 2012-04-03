class AddAttributesToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :is_primary_contact, :boolean
    add_column :users, :title, :string
    add_column :users, :dob, :date
    add_column :users, :ethnic_origin, :string
    add_column :users, :family_id, :integer
    add_column :users, :is_employee, :boolean
    add_column :users, :designations, :integer
    add_column :users, :ext_attr1, :string
    add_column :users, :ext_attr2, :string
    add_column :users, :ext_attr3, :string
    add_column :users, :ext_attr4, :string
    add_column :users, :ext_attr5, :string
  end

  def self.down
    remove_column :users, :is_primary_contact
    remove_column :users, :title
    remove_column :users, :dob
    remove_column :users, :ethnic_origin
    remove_column :users, :family_id
    remove_column :users, :is_employee
    remove_column :users, :designations
    remove_column :users, :ext_attr1
    remove_column :users, :ext_attr2
    remove_column :users, :ext_attr3
    remove_column :users, :ext_attr4
    remove_column :users, :ext_attr5
  end
end
