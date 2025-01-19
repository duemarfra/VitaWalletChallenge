# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  btc_balance     :decimal(20, 8)   default(0.0), not null
#  email           :string
#  password_digest :string           not null
#  session_token   :string
#  usd_balance     :decimal(15, 2)   default(0.0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  has_secure_password

  has_many :transactions, dependent: :destroy

  before_save :downcase_attributes
  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 },
                    format: { with: /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i }
  # validates :password, presence: true, length: { minimum: 6 }
  validates :password, length: { minimum: 6 }, unless: -> { password.blank? }
  validates :usd_balance, numericality: { greater_than_or_equal_to: 0 }
  validates :btc_balance, numericality: { greater_than_or_equal_to: 0 }

  # Method for creating and assigning a token
  def create_token
    self.session_token = SecureRandom.base64(64)
    save!
  end

  # Method for delete token
  def destroy_token
    self.session_token = nil
    save!
  end

  # Currency formatting methods
  def formatted_usd_balance
    format('USD: %.2f', usd_balance).gsub('.', ',')
  end

  def formatted_btc_balance
    format('BTC: %.8f', btc_balance).gsub('.', ',')
  end

  private

  def downcase_attributes
    self.email = email.downcase
  end
end
