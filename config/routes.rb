Rails.application.routes.draw do
  root 'welcome#home'

  #resource :wizard do
    #get :part1
    #get :part2
    #get :part3
    #post :validate_part
  #end
  # Explanation of routes generated above:
  # #part1_wizard_path returns GET "/wizard/part1", which maps to wizards#part1
  # part2_wizard_path returns GET "/wizard/part2", which maps to wizards#part2
  # part3_wizard_path returns GET "/wizard/part3", which maps to wizards#part3
  # validate_part_wizard_path returns POST "/wizard/validate_part", which maps to wizards#validate_part

  #get '/signup' => 'users#new'
  #post '/users' => 'users#create'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  resources :users, only: [:new, :create, :index, :show, :edit, :update, :destroy]
  resources :wizard_parts

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
