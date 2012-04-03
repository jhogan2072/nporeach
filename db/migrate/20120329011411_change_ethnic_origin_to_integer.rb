class ChangeEthnicOriginToInteger < ActiveRecord::Migration
  def up
    change_column :users, :ethnic_origin, :integer
  end

  def down
    change_column :users, :ethnic_origin, :string
  end
end
