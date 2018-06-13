Rails.application.routes.draw do
  root 'welcome#home'

  get '/signup' => 'users#new'
  post '/users' => 'users#create'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  resources :users

  resources :obsessions do
    resources :comments, only: [:index, :new, :create]
  end

  resources :plans do
    resources :steps
  end

  resources :themes, only: [:index, :new, :create]
  resources :searches

  get '/auth/twitter/callback' => 'sessions#create'
  get '/privacy' => 'welcome#privacy'
  get '/terms' => 'welcome#terms'
end

# resources :users

# resources :obsessions do
#  resources :comments, only: [:index, :new, :create]
# end

#  resources :plans do
#   resources :steps
#  end
