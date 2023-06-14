Rails.application.routes.draw do
  resources :bookmarks, only: %i[create]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
  get 'items/search'
  get 'items/keysearch'
  resources :users do
    resources :follow_lists, only: [:index]
    resources :follower_lists, only: [:index]
    resources :bookmarks, only: [:index]
    resource :relationships, only: [:create, :destroy]
    get 'followings' => 'relationships#followings', as: 'followings'
    get 'followers' => 'relationships#followers', as: 'followers'
  end
  # Defines the root path route ("/")
  # root "articles#index"
  root "top#first_view"
  delete '/bookmarks', to: 'bookmarks#destroy'
end
