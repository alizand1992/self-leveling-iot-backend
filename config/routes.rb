# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, defaults: { format: :json }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :application, only: :index
  post '/user/get_data', to: 'application#user_data'

  resources :notifications, only: %i[create index show update]
  resources :triggers, only: %i[create index]
  get '/triggers/attributes', to: 'triggers#attributes'

  get '/devices/sync', to: 'devices#sync'
end
