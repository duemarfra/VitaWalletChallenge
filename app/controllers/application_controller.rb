class ApplicationController < ActionController::API
  include Language

  def authenticate_user!(user_id)
    return render(json: { message: I18n.t('application.uid_is_null') }, status: :unauthorized) if user_id.nil?

    token_bearer = request.headers['Authorization']&.split(' ')&.last
    return render(json: { message: I18n.t('application.token_is_null') }, status: :unauthorized) if token_bearer.nil?

    @current_user = User.find_by(id: user_id)
    return render(json: { message: I18n.t('application.user_not_found') }, status: :unauthorized) if @current_user.nil?

    token_status = token_is_valid?(@current_user.session_token, token_bearer)
    return render(json: { message: token_status[:message] }, status: :unauthorized) unless token_status[:valid]

    true
  end

  private

  def token_is_valid?(token_session, token_bearer)
    if token_session != token_bearer
      { valid: false, message: I18n.t('application.invalid_token') }
    else
      { valid: true, message: I18n.t('application.token_its_ok') }
    end
  end
end
