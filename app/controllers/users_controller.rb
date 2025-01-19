class UsersController < ApplicationController
  before_action -> { authenticate_user!(params[:id]) }, only: %i[sign_out fund_account]

  def index
    @users = User.all
    render json: { users: @users }
  end

  def create
    @user = User.new(params_for_create_user)
    if @user.save
      render json: { message: I18n.t('user.created'), user: @user }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def sign_in
    @user = User.find_by(email: params[:email].downcase)
    if @user&.authenticate(params[:password])
      @user.create_token

      render json: { message: I18n.t('user.signed_in'), user: @user }, status: :ok
    else
      render json: { message: I18n.t('user.invalid_credentials') }, status: :unauthorized
    end
  end

  def sign_out
    @current_user.destroy_token
    render json: { message: I18n.t('user.signed_out') }, status: :ok
  end

  def fund_account
    currency_permitted = %w[usd btc]
    currency = params[:currency]&.downcase
    amount = params[:amount].to_f

    unless currency_permitted.include?(currency)
      return render json: { message: I18n.t('user.currency_not_found') }, status: :unprocessable_entity
    end

    if amount.nil?
      return render(json: { message: I18n.t('user.amount_not_found') },
                    status: :unprocessable_entity)
    end

    previous_balance = balance(currency)

    if currency == 'usd'
      @current_user.update!(usd_balance: @current_user.usd_balance + amount)
    else
      @current_user.update!(btc_balance: @current_user.btc_balance + amount)
    end

    current_balance = balance(currency)

    render json: {
      message: I18n.t('user.funds_added', currency: currency.upcase, amount: amount),
      user: {
        email: @current_user.email,
        previous_balance: previous_balance,
        amount: "+ #{amount}",
        current_balance: current_balance
      }
    }, status: :ok
  end

  def btc_price
    prices = BtcPriceService.fetch_btc_prices

    if prices[:error]
      render json: { message: prices[:error] }, status: :unprocessable_entity
    else
      render json: {
        message: I18n.t('user.btc_price_success'),
        data: {
          usd: prices[:usd],
          gbp: prices[:gbp],
          eur: prices[:eur]
        }
      }, status: :ok
    end
  end

  private

  def balance(currency, user = @current_user)
    if currency == 'usd'
      user.formatted_usd_balance
    elsif currency == 'btc'
      user.formatted_btc_balance
    end
  end

  def params_for_create_user
    params.require(:user).permit(
      :email,
      :password
    )
  end
end
