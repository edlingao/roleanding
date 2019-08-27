Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: 'registrations'}
  resources :friendships, only: [:create, :update, :destroy]
  resources :posts
  resources :comments
  
  get 'home/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"
end
