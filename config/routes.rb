Rails.application.routes.draw do
  root 'welcome#home'
  get '/signup' => 'users#new'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/auth/twitter/callback' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  resources :users, except: :new
  resources :obsessions, only: :index
  resources :plans, only: :index
  resources :themes, only: [:index, :new, :create]

  resources :obsessions, shallow: true do
    resources :comments, only: [:index, :new, :create]
    resources :plans do
      resources :steps
    end
  end
end
