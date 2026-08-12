# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "portal/dashboard#show"

  resources :suppliers
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  resources :products
  resources :categories
  resources :product_families
  devise_for :users,
    path: "",
    path_names: {sign_in: "login", sign_out: "logout", password: "passwort"},
    controllers: {sessions: "users/sessions", passwords: "users/passwords"}
  ActiveAdmin.routes(self)

  scope module: :portal, as: :portal do
    resource :work_schedule, path: "dienstplan", only: :show
    resources :working_hours, path: "arbeitszeiten", except: :show
    resources :expenses, path: "auslagen", except: :show
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  match "*unmatched", to: "application#route_not_found", via: :all
end
