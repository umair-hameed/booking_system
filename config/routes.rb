Rails.application.routes.draw do
  devise_for :users
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "rooms#index"

    resources :rooms

    resources :bookings do
      member do
        patch :cancel
        patch :confirm
      end
    end

    get 'multiple_bookings_form', to: 'bookings#multiple_bookings_form', as: :multiple_bookings_form
    post 'multiple_bookings', to: 'bookings#multiple_bookings', as: :multiple_bookings

    # Optional: Audit Logs (bonus feature)
    resources :audit_logs, only: [:index]
end
