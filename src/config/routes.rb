# == Route Map
#
#                      Prefix Verb   URI Pattern                                     Controller#Action
#                        root GET    /                                               schedules#index
#                   home_page GET    /home(.:format)                                 pages#home
#              words_sessions GET    /sessions/words(.:format)                       sessions#words
#             export_sessions GET    /sessions/export(.:format)                      sessions#export
#         popularity_sessions GET    /sessions/popularity(.:format)                  sessions#popularity
#          session_attendance DELETE /sessions/:session_id/attendance(.:format)      attendances#destroy
#                             POST   /sessions/:session_id/attendance(.:format)      attendances#create
#       session_presentations GET    /sessions/:session_id/presentations(.:format)   presentations#index
#                             POST   /sessions/:session_id/presentations(.:format)   presentations#create
#                    sessions GET    /sessions(.:format)                             sessions#index
#                             POST   /sessions(.:format)                             sessions#create
#                 new_session GET    /sessions/new(.:format)                         sessions#new
#                edit_session GET    /sessions/:id/edit(.:format)                    sessions#edit
#                     session GET    /sessions/:id(.:format)                         sessions#show
#                             PATCH  /sessions/:id(.:format)                         sessions#update
#                             PUT    /sessions/:id(.:format)                         sessions#update
#                 attendances GET    /attendances(.:format)                          attendances#index
#                participants GET    /participants(.:format)                         participants#index
#                             POST   /participants(.:format)                         participants#create
#             new_participant GET    /participants/new(.:format)                     participants#new
#            edit_participant GET    /participants/:id/edit(.:format)                participants#edit
#                 participant GET    /participants/:id(.:format)                     participants#show
#                             PATCH  /participants/:id(.:format)                     participants#update
#                             PUT    /participants/:id(.:format)                     participants#update
#                    category GET    /categories/:id(.:format)                       categories#show
#                       event GET    /events/:id(.:format)                           events#show
#                   new_login GET    /login(.:format)                                user_sessions#new
#                       login POST   /login(.:format)                                user_sessions#create
#                      logout DELETE /logout(.:format)                               user_sessions#destroy
#             password_resets POST   /password_resets(.:format)                      password_resets#create
#          new_password_reset GET    /password_resets/new(.:format)                  password_resets#new
#         edit_password_reset GET    /password_resets/:id/edit(.:format)             password_resets#edit
#              password_reset PATCH  /password_resets/:id(.:format)                  password_resets#update
#                             PUT    /password_resets/:id(.:format)                  password_resets#update
#                    schedule GET    /schedule(.:format)                             schedules#index
#                schedule_ics GET    /schedule.ics(.:format)                         schedules#ical
#                       admin GET    /admin(.:format)                                admin#show
#                admin_config GET    /admin/config(.:format)                         admin/configs#show
#                             POST   /admin/config(.:format)                         admin/configs#create
#              admin_sessions GET    /admin/sessions(.:format)                       admin/sessions#index
#                             POST   /admin/sessions(.:format)                       admin/sessions#create
#           new_admin_session GET    /admin/sessions/new(.:format)                   admin/sessions#new
#          edit_admin_session GET    /admin/sessions/:id/edit(.:format)              admin/sessions#edit
#               admin_session GET    /admin/sessions/:id(.:format)                   admin/sessions#show
#                             PATCH  /admin/sessions/:id(.:format)                   admin/sessions#update
#                             PUT    /admin/sessions/:id(.:format)                   admin/sessions#update
#                             DELETE /admin/sessions/:id(.:format)                   admin/sessions#destroy
#       admin_event_timeslots GET    /admin/events/:event_id/timeslots(.:format)     admin/timeslots#index
#                             POST   /admin/events/:event_id/timeslots(.:format)     admin/timeslots#create
#    new_admin_event_timeslot GET    /admin/events/:event_id/timeslots/new(.:format) admin/timeslots#new
#           admin_event_rooms POST   /admin/events/:event_id/rooms(.:format)         admin/rooms#create
#        new_admin_event_room GET    /admin/events/:event_id/rooms/new(.:format)     admin/rooms#new
#                admin_events GET    /admin/events(.:format)                         admin/events#index
#                             POST   /admin/events(.:format)                         admin/events#create
#             new_admin_event GET    /admin/events/new(.:format)                     admin/events#new
#            edit_admin_event GET    /admin/events/:id/edit(.:format)                admin/events#edit
#                 admin_event GET    /admin/events/:id(.:format)                     admin/events#show
#                             PATCH  /admin/events/:id(.:format)                     admin/events#update
#                             PUT    /admin/events/:id(.:format)                     admin/events#update
#                             DELETE /admin/events/:id(.:format)                     admin/events#destroy
#         edit_admin_timeslot GET    /admin/timeslots/:id/edit(.:format)             admin/timeslots#edit
#              admin_timeslot PATCH  /admin/timeslots/:id(.:format)                  admin/timeslots#update
#                             PUT    /admin/timeslots/:id(.:format)                  admin/timeslots#update
#             edit_admin_room GET    /admin/rooms/:id/edit(.:format)                 admin/rooms#edit
#                  admin_room PATCH  /admin/rooms/:id(.:format)                      admin/rooms#update
#                             PUT    /admin/rooms/:id(.:format)                      admin/rooms#update
#     export_admin_presenters GET    /admin/presenters/export(.:format)              admin/presenters#export
# export_all_admin_presenters GET    /admin/presenters/export_all(.:format)          admin/presenters#export_all
#            admin_presenters GET    /admin/presenters(.:format)                     admin/presenters#index
#        edit_admin_presenter GET    /admin/presenters/:id/edit(.:format)            admin/presenters#edit
#             admin_presenter PATCH  /admin/presenters/:id(.:format)                 admin/presenters#update
#                             PUT    /admin/presenters/:id(.:format)                 admin/presenters#update

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
