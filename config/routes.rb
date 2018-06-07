Rails.application.routes.draw do
  root 'welcome#home'

  resource :wizard do
    get :part1
    get :part2
    get :part3

    post :validate_part
    # Routes generated:
    # get "/wizard/part1" => wizards#part1
    # get "/wizard/part2" => wizards#part2
    # get "/wizard/part3" => wizards#part3
    # post "/wizard/validate_part" => wizards#validate_part
  end

  #get '/signup' => 'users#new'
  #post '/users' => 'users#create'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  #resources :users, only: [:index, :show, :edit, :update, :destroy]

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
