Rails.application.routes.draw do
  root   'static_pages#home'
  get    '/help',    to: 'static_pages#help'
  get    '/about',   to: 'static_pages#about'
  get    '/contact', to: 'static_pages#contact'
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users
  # ユーザーの有効化を行うリソース
  resources :account_activations, only: [:edit]
  # パスワード再設定を行うリソース(newとcreateがエントリー、editとupdateが再設定)
  resources :password_resets, only: [:new, :create, :edit, :update]
end
