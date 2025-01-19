class TransactionsController < ApplicationController
  before_action -> { authenticate_user!(params[:user_id]) }, only: %i[index show create]

  def index
    transactions = @current_user.transactions
    if transactions.any?
      render json: { transactions: transactions }
    else
      render json: { message: I18n.t('transaction.no_transactions') }, status: :ok
    end
  end

  def show
    transaction = @current_user.transactions.find_by(id: params[:id])
    if transaction
      render json: { transaction: transaction }
    else
      render json: { message: I18n.t('transaction.not_found') }, status: :not_found
    end
  end

  def create
    is_buy = params[:is_buy].to_s.strip.downcase == 'true'

    amount_sent = params[:amount_sent].to_f

    return render json: { message: I18n.t('transaction.is_buy_required') }, status: :unprocessable_entity if is_buy.nil?

    prices = BtcPriceService.fetch_btc_prices
    return render json: { message: prices[:error] }, status: :unprocessable_entity if prices[:error]

    rate = prices[:usd]
    amount_received = is_buy ? (amount_sent / rate).round(8) : (amount_sent * rate).round(2)

    if is_buy && @current_user.usd_balance < amount_sent
      return render json: { message: I18n.t('transaction.insufficient_usd') }, status: :unprocessable_entity
    elsif !is_buy && @current_user.btc_balance < amount_sent
      return render json: { message: I18n.t('transaction.insufficient_btc') }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      transaction = Transaction.create!(
        user: @current_user,
        is_buy: is_buy,
        amount_sent: amount_sent,
        amount_received: amount_received
      )

      if is_buy
        @current_user.update!(
          usd_balance: @current_user.usd_balance - amount_sent,
          btc_balance: @current_user.btc_balance + amount_received
        )
      else
        @current_user.update!(
          btc_balance: @current_user.btc_balance - amount_sent,
          usd_balance: @current_user.usd_balance + amount_received
        )
      end

      render json: {
        message: I18n.t('transaction.success'),
        transaction: {
          is_buy: is_buy,
          amount_sent: amount_sent.to_s,
          amount_received: amount_received.to_s
        }
      }, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { message: e.message }, status: :unprocessable_entity
  end
end
