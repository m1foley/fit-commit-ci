class CreateRepos < ActiveRecord::Migration[5.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    create_table :repos, id: :uuid do |t|
      t.integer :github_id, null: false
      t.string :name, null: false
      t.boolean :private, null: false, default: false
      t.boolean :active, null: false, default: false

      t.timestamps
    end
  end
end
