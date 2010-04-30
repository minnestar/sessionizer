ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'sessions', :action => 'index'
  map.resources :sessions, :only => [:show, :new, :create, :update, :edit] do |session|
    session.resource :attendance, :only => [:create]
  end
  map.resources :participants, :only => [:show, :edit, :update]
end
