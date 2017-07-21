class AddIndexForGithubIdToRepos < ActiveRecord::Migration[5.1]
  def change
    add_index :repos, :github_id, unique: true
  end
end
