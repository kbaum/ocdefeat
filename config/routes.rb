Rails.application.routes.draw do
  root 'welcome#home'

  get '/signup' => 'users#new'
  post '/users' => 'users#create'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  resources :users, only: [:index, :show, :edit, :update, :destroy]

  resources :obsessions do
    resources :comments, only: [:create, :index, :edit, :update, :destroy]
  end

  resources :plans do
    resources :steps
  end

  resources :themes
  resources :searches

  get '/auth/twitter/callback' => 'sessions#create'

  get '/privacy' => 'welcome#privacy'
  get '/terms' => 'welcome#terms'
end
