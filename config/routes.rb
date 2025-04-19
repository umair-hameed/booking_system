Rails.application.routes.draw do
  devise_for :users
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  # root "home#index"
  root "rooms#index"

    # Room Management (admin)
    # resources :rooms, only: [:index, :show]
    resources :rooms

    # Booking Management
    resources :bookings, only: [:index, :new, :create, :show] do
      member do
        patch :cancel         # /bookings/:id/cancel (for cancellations)
      end
    end

    # Optional: Admin route to manage rooms
    # namespace :admin do
    #   resources :rooms
    #   resources :bookings, only: [:index, :show]
    # end

    # Optional: Audit Logs (bonus feature)
    resources :audit_logs, only: [:index]
end
