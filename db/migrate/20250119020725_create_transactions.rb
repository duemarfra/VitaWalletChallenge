class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.boolean :is_buy, null: false
      t.decimal :amount_sent, precision: 20, scale: 8, null: false
      t.decimal :amount_received, precision: 20, scale: 8, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
