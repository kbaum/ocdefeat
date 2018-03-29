Rails.application.routes.draw do
  root 'welcome#home'

  get '/signup' => 'users#new'
  post '/users' => 'users#create'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'

  resources :users, only: [:show, :edit, :update, :destroy]

  get '/auth/facebook/callback' => 'sessions#create'
end
