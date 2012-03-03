ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'pages', :action => 'home'
  map.resources :sessions, :only => [:index, :show, :new, :create, :update, :edit], :collection => { :words => :get, :export => :get, :popularity => :get } do |session|
    session.resource :attendance, :only => [:create]
  end
  map.resources :participants, :only => [:show, :edit, :update]
  map.resources :categories, :only => :show
  map.resources :events, :only => [:index, :show]

  map.new_login '/login', :controller => 'user_sessions', :action => 'new', :conditions => {:method => :get}
  map.login '/login', :controller => 'user_sessions', :action => 'create', :conditions => {:method => :post}

  map.namespace :admin do |admin|
    admin.resources :sessions
    admin.resources :events
    admin.resources :presenters, :collection => { :export => :get }
  end
    
end
