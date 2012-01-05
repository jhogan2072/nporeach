class RenameSaasAdmin < ActiveRecord::Migration
  def change
    rename_table :saas_admins, :admins
  end
end
