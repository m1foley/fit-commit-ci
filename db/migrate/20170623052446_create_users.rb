class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    create_table :users, id: :uuid do |t|
      t.string :username, null: false
      t.string :remember_token, null: false

      t.timestamps null: false

      t.index :username, unique: true
      t.index :remember_token, unique: true
    end
  end
end
