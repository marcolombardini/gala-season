require 'sidekiq/web'

Rails.application.routes.draw do
  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: '127.0.0.1') do
    get '(*path)', to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end

  mount Sidekiq::Web => '/sidekiq'

  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :users do
    get 'sign_in', to: 'sessions#new'
    post 'sign_in', to: 'sessions#create'
    delete 'sign_out', to: 'sessions#destroy'
    get 'sign_up', to: 'registrations#new'
    post 'sign_up', to: 'registrations#create'
  end

  namespace :organizations do
    get 'sign_in', to: 'sessions#new'
    post 'sign_in', to: 'sessions#create'
    delete 'sign_out', to: 'sessions#destroy'
    get 'sign_up', to: 'registrations#new'
    post 'sign_up', to: 'registrations#create'
  end

  namespace :dashboard do
    resources :events, only: %i[index new create edit update]
  end

  get '/events/:id', to: 'events#show', as: :event
  post '/events/:event_id/attend', to: 'attendances#create', as: :event_attend
  delete '/events/:event_id/attend', to: 'attendances#destroy', as: :event_unattend

  get '/o/:slug', to: 'organization_profiles#show', as: :organization_profile
  post '/o/:slug/follow', to: 'follows#create', as: :organization_follow
  delete '/o/:slug/follow', to: 'follows#destroy', as: :organization_unfollow
  get '/u/:username', to: 'profiles#show', as: :user_profile

  root 'home#index'
end
