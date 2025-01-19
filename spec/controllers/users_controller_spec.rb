require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:valid_user_params) do
    { user: { email: 'test@example.com', password: 'password123' } }
  end

  let(:invalid_user_params) do
    { user: { email: 'invalid_email', password: '' } }
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new user' do
        expect do
          post :create, params: valid_user_params
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('user.created'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new user' do
        expect do
          post :create, params: invalid_user_params
        end.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end

  describe 'POST #sign_in' do
    let!(:user) { User.create!(email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'signs in the user and returns a token' do
        post :sign_in, params: { email: user.email, password: 'password123' }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('user.signed_in'))
        expect(User.find(user.id).session_token).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns an unauthorized status' do
        post :sign_in, params: { email: user.email, password: 'wrong_password' }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('user.invalid_credentials'))
      end
    end
  end

  describe 'DELETE #sign_out' do
    let!(:user) { User.create!(email: 'test@example.com', password: 'password123', session_token: 'token123') }

    it 'destroys the session token' do
      request.headers['Authorization'] = "Bearer #{user.session_token}"
      delete :sign_out, params: { id: user.id }

      expect(response).to have_http_status(:ok)
      expect(User.find(user.id).session_token).to be_nil
    end
  end

  describe 'PUT #fund_account' do
    let!(:user) do
      User.create!(email: 'test@example.com', password: 'password123', usd_balance: 100.0, btc_balance: 0.01,
                   session_token: 'token123')
    end

    before do
      request.headers['Authorization'] = "Bearer #{user.session_token}"
    end

    context 'with valid USD funding' do
      it 'increases the USD balance' do
        expect do
          put :fund_account, params: { id: user.id, currency: 'usd', amount: 50.0 }
        end.to change { user.reload.usd_balance }.by(50.0)

        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['message']).to eq(I18n.t('user.funds_added', currency: 'USD', amount: 50.0))
        expect(response_body['user']['previous_balance']).to eq('USD: 100,00')
        expect(response_body['user']['current_balance']).to eq('USD: 150,00')
      end
    end

    context 'with valid BTC funding' do
      it 'increases the BTC balance' do
        expect do
          put :fund_account, params: { id: user.id, currency: 'btc', amount: 0.005 }
        end.to change { user.reload.btc_balance }.by(0.005)

        expect(response).to have_http_status(:ok)
        response_body = JSON.parse(response.body)
        expect(response_body['message']).to eq(I18n.t('user.funds_added', currency: 'BTC', amount: 0.005))
        expect(response_body['user']['previous_balance']).to eq('BTC: 0,01000000')
        expect(response_body['user']['current_balance']).to eq('BTC: 0,01500000')
      end
    end

    context 'with invalid currency' do
      it 'returns an error message' do
        put :fund_account, params: { id: user.id, currency: 'eur', amount: 50.0 }

        expect(response).to have_http_status(:unprocessable_entity)
        response_body = JSON.parse(response.body)
        expect(response_body['message']).to eq(I18n.t('user.currency_not_found'))
      end
    end
  end
end
