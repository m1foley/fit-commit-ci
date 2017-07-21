class AddInOrganizationToRepos < ActiveRecord::Migration[5.1]
  def change
    add_column :repos, :in_organization, :boolean, null: false, default: false
  end
end
