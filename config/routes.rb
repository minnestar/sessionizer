ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'sessions', :action => 'index'
  map.resources :sessions, :only => [:index, :show, :new, :create, :update]
end
