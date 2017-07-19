class CreateMemberships < ActiveRecord::Migration[5.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    create_table :memberships, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, index: false
      t.references :repo, type: :uuid, foreign_key: true, index: true
      t.boolean :admin, null: false, default: false

      t.timestamps null: false

      t.index [ :user_id, :repo_id ], unique: true
    end
  end
end
