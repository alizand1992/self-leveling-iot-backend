# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, defaults: { format: :json }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :application, only: :index
  post '/user/get_data', to: 'application#user_data'

  resources :notifications, only: %i[create index show update]
  resources :triggers, only: %i[create index update destroy]
  get '/triggers/attributes', to: 'triggers#attributes'

  resources :devices, only: %i[index]
  get '/devices/registered_devices', to: 'devices#registered_devices'
  get '/devices/registered_devices_with_details', to: 'devices#registered_devices_with_details'
  post '/devices/register', to: 'devices#register'
  post '/devices/issue_command', to: 'devices#issue_command'
  patch '/devices/unregister', to: 'devices#unregister'
  get '/devices/sync', to: 'devices#sync'
end
