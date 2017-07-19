class CreateOwners < ActiveRecord::Migration[5.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    create_table :owners, id: :uuid do |t|
      t.integer :github_id, null: false
      t.string :name, null: false
      t.boolean :organization, default: false, null: false

      t.timestamps null: false

      t.index :github_id, unique: true
    end
  end
end
