class AddOwnerToRepos < ActiveRecord::Migration[5.1]
  def change
    add_reference :repos, :owner, type: :uuid, index: true, foreign_key: true
  end
end
