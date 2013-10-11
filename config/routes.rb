
  get 'bulk_time_entries', :to => 'bulk_time_entries#index'

  post 'bulk_time_entries/load_assigned_issues', :to => 'bulk_time_entries#load_assigned_issues'

  post 'bulk_time_entries/save', :to => 'bulk_time_entries#save'
  
  post 'bulk_time_entries/add_entry', :to => 'bulk_time_entries#add_entry'