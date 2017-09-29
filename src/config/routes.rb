Sessionizer::Application.routes.draw do
  root to: 'schedules#index'

  get '/home' => 'pages#home', as: :home_page

  resources :sessions, :only => [:index, :show, :new, :create, :update, :edit] do
    collection do
      get :words
      get :export
      get :popularity
    end
    resource :attendance, :only => [:create, :destroy]
    resources :presentations, :only => [:index, :create]
  end
  get '/attendances' => 'attendances#index'

  resources :participants, :except => [:destroy]
  resources :categories, only: :show
  resources :events, only: :show

  match '/login' => 'user_sessions#new', :as => :new_login, :via => 'get'
  match '/login' => 'user_sessions#create', :as => :login, :via => 'post'
  match '/logout' => 'user_sessions#destroy', :as => :logout, :via => 'delete'

  resources :password_resets, :only => [ :new, :create, :edit, :update ]

  #something is still off here
  get '/schedule' => 'schedules#index', as: :schedule
  get '/schedule.ics' => 'schedules#ical', as: :schedule_ics

  resource :admin, controller: 'admin', only: [:show]
  namespace :admin do
    resource :config, only: [:show, :create]
    resources :sessions
    resources :events do
      resources :timeslots, only: [:index, :new, :create]
      resources :rooms, only: [:new, :create]
    end
    resources :timeslots, only: [:edit, :update]
    resources :rooms, only: [:edit, :update]
    resources :presenters, only: [:index, :edit, :update] do
      collection do
        get 'export'
        get 'export_all'
      end
    end
  end
end
