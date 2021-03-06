Notch::Application.routes.draw do

  devise_for :users, controllers: { registrations: 'registrations' }

  # Authentication
  devise_scope :user do
    get '/login' => 'devise/sessions#new', as: :login
    get '/logout' => 'sessions#destroy', :as => :logout
    get '/signup' => 'registrations#new', :as => :signup
    scope 'my' do
      get 'profile', to: 'registrations#edit'
      put 'profile/update', to: 'registrations#update'
      get 'password/edit', to: 'registrations#edit_password'
      put 'password/update', to: 'registrations#update_password'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with 'rake routes'.

  unauthenticated do
    get '/logout' => redirect('/')
  end

  authenticate :user, ->(u) { u.super_admin? } do
    get '/delayed_job' => DelayedJobWeb, :anchor => false
    put '/delayed_job' => DelayedJobWeb, :anchor => false
    post '/delayed_job' => DelayedJobWeb, :anchor => false

    ActiveAdmin.routes(self)
    namespace :superadmin do
      root to: 'users#index'
      resources :users
    end

  end

  authenticate :user do

    resources :teams do
      member do
        get :settings
      end
    end

    get "pages/about"
    get "pages/my_personal_calendar"
    get "pages/my_personal_calendar_members"
    get "pages/my_personal_calendar_tags"
    get "pages/home"
    get "pages/settings"
    get "pages/create_team_personal"
    get "pages/onboarding_1"
    get "pages/onboarding_create_team"
    get "pages/onboarding_invite_members"

    get "home/index"

  end

  authenticated :user do
    get '/pages' => 'pages#index', as: :pages
    get 'pages/contact_us'

    resources :contacts, only: [:create]
  end

  unauthenticated do
    as :user do
      root :to => 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_scope :user do
        post 'login' => 'sessions#create', as: 'login'
      end

      resources :users, only: [:show, :create, :update, :destroy], constraints: { id: /.*/ }
    end
  end


  root 'teams#index'
end
