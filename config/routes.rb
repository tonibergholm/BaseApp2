# See how all your routes lay out with "rake routes"
ActionController::Routing::Routes.draw do |map|

  map.devise_for :users

  # map.resources :announcements

  
  # RESTful rewrites
  
  map.open_id_complete '/opensession', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.open_id_create '/opencreate', :controller => "users", :action => "create", :requirements => { :method => :get }
    
  # map.resources :users, :member => { :edit_password => :get,
  #                                    :update_password => :put,
  #                                    :edit_email => :get,
  #                                    :update_email => :put,
  #                                    :edit_avatar => :get, 
  #                                    :update_avatar => :put }
                            
  map.resource :session
    
  # Profiles
  map.resources :profiles
  
  # Administration
  map.namespace(:admin) do |admin|
    admin.root :controller => 'dashboard', :action => 'index'
    admin.resources :settings
    admin.resources :announcements
    admin.resources :commits
    admin.resources :users, :member => { :suspend   => :put,
                                         :unsuspend => :put,
                                         :activate  => :put, 
                                         :purge     => :delete,
                                         :reset_password => :put },
                            :collection => { :pending   => :get,
                                             :active    => :get, 
                                             :suspended => :get, 
                                             :deleted   => :get }
  end
  
  # Dashboard as the default location
  map.root :controller => 'dashboard', :action => 'index'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
