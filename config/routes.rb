Rails.application.routes.draw do
  root 'welcome#home'
  get '/about' => 'welcome#about'
  get '/signup' => 'users#new'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/auth/twitter/callback' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'

  resources :users, except: :new
  resources :plans, only: :index
  resources :themes, except: [:show]

  resources :obsessions, shallow: true do
    resources :comments, except: :show
    resources :plans do
      resources :steps, except: :new
    end
  end
end
