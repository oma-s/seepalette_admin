class RenameAdminUsersToUsers < ActiveRecord::Migration[8.0]
  def change
    rename_table :admin_users, :users
  end
end
