class AddHookIdToRepos < ActiveRecord::Migration[5.1]
  def change
    add_column :repos, :hook_id, :integer
  end
end
