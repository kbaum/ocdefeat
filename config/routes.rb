Rails.application.routes.draw do
  root 'welcome#home'
  get '/signup' => 'users#new'
  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/auth/twitter/callback' => 'sessions#create'
  delete '/logout' => 'sessions#destroy'
end
