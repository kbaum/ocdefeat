Rails.application.routes.draw do
  root 'welcome#home'

  get '/signup' => 'users#new'
  post '/users' => 'users#create'

  resources :users, only: [:show, :edit, :update, :destroy]
end
