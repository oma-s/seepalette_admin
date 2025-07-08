# frozen_string_literal: true

Rails.application.routes.draw do
  resources :suppliers
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  
  resources :products
  resources :categories
  resources :product_families
  resources :expenses

  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up', to: 'rails/health#show', as: :rails_health_check

  root to: redirect('admin')

  match '*unmatched', to: 'application#route_not_found', via: :all
end
