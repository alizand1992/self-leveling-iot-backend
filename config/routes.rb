# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, defaults: { format: :json }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :application, only: :index
  post '/user/get_data', to: 'application#user_data'

  resources :notifications, only: :create
end
