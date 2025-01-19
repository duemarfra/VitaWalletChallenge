require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  let!(:user) do
    User.create!(
      email: 'test@example.com',
      password: 'password123',
      usd_balance: 1000.0,
      btc_balance: 0.5,
      session_token: 'token123'
    )
  end

  let!(:transaction) do
    Transaction.create!(
      user: user,
      is_buy: true,
      amount_sent: 500.0,
      amount_received: 0.01
    )
  end

  before do
    request.headers['Authorization'] = "Bearer #{user.session_token}"
  end

  describe 'GET #index' do
    it 'returns all transactions for the current user' do
      get :index, params: { user_id: user.id }

      expect(response).to have_http_status(:ok)
      transactions = JSON.parse(response.body)['transactions']
      expect(transactions.size).to eq(1)
      expect(transactions.first['amount_sent']).to eq('500.0')
    end
  end

  describe 'GET #show' do
    context 'when the transaction exists' do
      it 'returns the transaction' do
        get :show, params: { user_id: user.id, id: transaction.id }

        expect(response).to have_http_status(:ok)
        returned_transaction = JSON.parse(response.body)['transaction']
        expect(returned_transaction['amount_sent']).to eq('500.0')
        expect(returned_transaction['amount_received']).to eq('0.01')
      end
    end

    context 'when the transaction does not exist' do
      it 'returns a not found error' do
        get :show, params: { user_id: user.id, id: -1 }

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('transaction.not_found'))
      end
    end
  end

  describe 'POST #create' do
    context 'when the transaction is a buy' do
      it 'creates a new transaction and updates balances' do
        allow(BtcPriceService).to receive(:fetch_btc_prices).and_return({ usd: 50_000.0 })

        expect do
          post :create, params: { user_id: user.id, is_buy: true, amount_sent: 500.0 }
        end.to change(Transaction, :count).by(1)

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['transaction']['is_buy']).to eq(true)
        expect(response_body['transaction']['amount_received']).to eq('0.01')
        user.reload
        expect(user.usd_balance).to eq(500.0)
        expect(user.btc_balance).to eq(0.51)
      end
    end

    context 'when the transaction is a sell' do
      it 'creates a new transaction and updates balances' do
        allow(BtcPriceService).to receive(:fetch_btc_prices).and_return({ usd: 50_000.0 })

        expect do
          post :create, params: { user_id: user.id, is_buy: false, amount_sent: 0.01 }
        end.to change(Transaction, :count).by(1)

        expect(response).to have_http_status(:created)
        response_body = JSON.parse(response.body)
        expect(response_body['transaction']['is_buy']).to eq(false)
        expect(response_body['transaction']['amount_received']).to eq('500.0')
        user.reload
        expect(user.usd_balance).to eq(1500.0)
        expect(user.btc_balance).to eq(0.49)
      end
    end

    context 'when there are insufficient funds for a buy' do
      it 'returns an error message' do
        post :create, params: { user_id: user.id, is_buy: true, amount_sent: 1500.0 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('transaction.insufficient_usd'))
      end
    end

    context 'when there are insufficient funds for a sell' do
      it 'returns an error message' do
        post :create, params: { user_id: user.id, is_buy: false, amount_sent: 1.0 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('transaction.insufficient_btc'))
      end
    end

    context 'when BTC price service fails' do
      it 'returns an error message' do
        allow(BtcPriceService).to receive(:fetch_btc_prices).and_return({ error: 'API error' })

        post :create, params: { user_id: user.id, is_buy: true, amount_sent: 500.0 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq('API error')
      end
    end
  end
end
