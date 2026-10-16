class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :username, null: false
      t.string :password_digest, null: false
      t.timestamps
    end

    add_index :accounts, "LOWER(username)", unique: true, name: "index_accounts_on_lower_username"
  end
end
