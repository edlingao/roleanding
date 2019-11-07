# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations', omniauth_callbacks: 'users/omniauth_callbacks' }
  resources :users, only: [:update]
  resources :friendships, only: %i[create update destroy]
  resources :posts
  resources :comments

  put '/like' => 'likes#create'
  delete '/like' => 'likes#destroy'

  get '/:username' => 'users#show', :constrain => { username: /[a-zA-Z-]+/ }, as: 'username'

  get '/me/:username' => 'users#index', :constrain => { username: /[a-zA-Z-]+/ }, as: 'user_home'
  put '/me/:username' => 'users#update'

  get '/home/search' => 'search#index', as: 'search'

  get 'home/notifications' => 'search#show', as: 'notifications'
  get ':username/post/:id/edit' => 'posts#edit', as: 'post_edit'

  get 'home/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'home#index'
end
