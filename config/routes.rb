Rails.application.routes.draw do

  get '/signup' => 'users#new'
  post '/users' => 'users#create'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  resources :users, only: [:show, :edit, :update, :destroy]

  resources :obsessions

  get '/auth/twitter/callback' => 'sessions#create'
end
