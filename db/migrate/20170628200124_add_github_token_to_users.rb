class AddGithubTokenToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :github_token, :string
  end
end
