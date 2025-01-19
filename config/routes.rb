Rails.application.routes.draw do
  get '/btc_price', to: 'users#btc_price'

  resources :users, only: %i[index create] do
    collection do
      post :sign_in
    end

    member do
      put :fund_account
      delete :sign_out
    end

    resources :transactions, only: %i[index show create]
  end
end
