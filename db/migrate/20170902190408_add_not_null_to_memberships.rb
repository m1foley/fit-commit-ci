class AddNotNullToMemberships < ActiveRecord::Migration[5.1]
  def change
    change_column :memberships, :user_id, :uuid, foreign_key: true, index: false, null: false
    change_column :memberships, :repo_id, :uuid, foreign_key: true, index: true, null: false
  end
end
