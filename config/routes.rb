Sessionizer::Application.routes.draw do
  #root :to => 'pages#home'

  root :to => 'schedules#index'

  resources :sessions, :only => [:index, :show, :new, :create, :update, :edit] do
    collection do
      get :words
      get :export
      get :popularity
    end
    resource :attendance, :only => [:create]
    resources :presentations, :only => [:index, :create]
  end

  resources :participants, :except => [:destroy]
  resources :categories, only: :show

  match '/login' => 'user_sessions#new', :as => :new_login, :via => 'get'
  match '/login' => 'user_sessions#create', :as => :login, :via => 'post'
  match '/logout' => 'user_sessions#destroy', :as => :logout, :via => 'delete'
  
  resources :password_resets, :only => [ :new, :create, :edit, :update ]

  #something is still off here
  get '/schedule' => 'schedules#index', as: :schedule
  get '/schedule.ics' => 'schedules#ical', as: :schedule_ics

  namespace :admin do
    resources :sessions
    resources :events do
      resources :timeslots
    end
    resources :presenters, only: [:index, :edit, :update] do
      collection do
        get 'export'
        get 'export_all'
      end
    end
  end
end
