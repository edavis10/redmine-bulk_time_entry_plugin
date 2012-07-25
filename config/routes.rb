ActionController::Routing::Routes.draw do |map|
  map.resources :bulk_time_entries,
    :only => [:index, :new, :load_assigned_issues, :create],
    :collection => {
      :load_assigned_issues => :get
    }
end
