class CreateBuilds < ActiveRecord::Migration[5.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    create_table :builds, id: :uuid do |t|
      t.references :repo, type: :uuid, foreign_key: true, index: true, null: false
      t.references :user, type: :uuid, foreign_key: true, index: false, null: true
      t.integer :pull_request_number, null: false
      t.string :head_sha, null: false
      t.integer :warning_count, default: 0, null: false
      t.integer :error_count, default: 0, null: false
      t.text :details
      t.datetime :completed_at
      t.timestamps null: false
    end
  end
end
