Rails.application.routes.draw do
  root 'welcome#home'

  get '/signup' => 'users#new'
  post '/users' => 'users#create'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  resources :users, only: [:index, :show, :edit, :update, :destroy]

  resources :obsessions

  resources :plans do
    resources :steps
  end

  resources :themes

  get '/auth/twitter/callback' => 'sessions#create'

  get '/privacy' => 'welcome#privacy'
  get '/terms' => 'welcome#terms'
end
