# == Schema Information
#
# Table name: transactions
#
#  id              :bigint           not null, primary key
#  amount_received :decimal(20, 8)   not null
#  amount_sent     :decimal(20, 8)   not null
#  is_buy          :boolean          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_transactions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Transaction < ApplicationRecord
  belongs_to :user

  validates :amount_sent, :amount_received, numericality: { greater_than: 0 }
end
