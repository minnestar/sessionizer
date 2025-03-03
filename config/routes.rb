Sessionizer::Application.routes.draw do
  root to: 'schedules#index'

  get '/home' => 'events#show', id: 'current', as: :home_page

  # Session actions available for all events
  resources :events, :only => [:show] do
    resources :sessions, :only => [:index]
    get '/schedule' => 'schedules#index'
  end

  # Session actions available only for the current event
  resources :sessions, :only => [:index, :show, :new, :create, :update, :edit, :destroy] do
    collection do
      get :words
      get :export
      get :popularity
    end
    resource :attendance, :only => [:create, :destroy]
    resources :presentations, :only => [:index, :create]
  end

  get '/attendances' => 'attendances#index'
  resources :participants, :except => [:destroy] do
    member do
      post :send_confirmation_email
      get :confirm_email
    end
  end
  resources :categories, only: :show

  match '/login' => 'user_sessions#new', :as => :new_login, :via => 'get'
  match '/login' => 'user_sessions#create', :as => :login, :via => 'post'
  match '/logout' => 'user_sessions#destroy', :as => :logout, :via => 'delete'

  resources :password_resets, :only => [ :new, :create, :edit, :update ]

  #something is still off here
  get '/schedule' => 'schedules#index', as: :schedule
  get '/schedule.ics' => 'schedules#ical', as: :schedule_ics

  get '/admin', to: redirect('/admin/legacy') # this used to be: `resource :admin, controller: 'admin', only: [:show]`
  namespace :admin do
    get '/', to: redirect('/admin/legacy') # temporary until we implement active admin
    get '/legacy', to: 'legacy/admin#show', as: :legacy
    namespace :legacy do
      resource :config, only: [:show, :create]
      resources :sessions
      resources :markdown_contents, path: 'markdown-contents'
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
end
