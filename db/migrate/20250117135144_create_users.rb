class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest, null: false
      t.string :session_token

      t.decimal :usd_balance, precision: 15, scale: 2, default: 0.00, null: false
      t.decimal :btc_balance, precision: 20, scale: 8, default: 0.00000000, null: false

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
