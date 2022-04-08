Rails.application.routes.draw do
 
  
  resources :leads  
  devise_for :users

  # get "leads", to: "leads#new"
  # post "leads", to: "leads#create"
  # get "leads/index", to: "leads#index"
   post "/", to: "leads#create"
  get "quotes", to: "quotes#new"
  post "quotes", to: "quotes#create"

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "home#index"
  get "commercial",  to: "home#commercial"
  get "residential", to: "home#residential"
  get 'intervention', to: 'intervention#intervention'


  resources :synthesized_messages
   # collection routes 
   resources :intervention do
    get :get_building, on: :collection
    get :get_battery, on: :collection
    get :get_column, on: :collection
    get :get_elevator, on: :collection
    end 
  
end
