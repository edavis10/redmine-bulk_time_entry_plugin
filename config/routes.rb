  #Redmine 1.4
ActionController::Routing::Routes.draw do |map|
  map.connect 'bulk_time_entries/:action.:format', :controller => 'bulk_time_entries'
end
