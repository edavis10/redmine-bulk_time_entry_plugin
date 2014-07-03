RedmineApp::Application.routes.draw do
  resources :bulk_time_entries,
    :only => [:index, :new, :create] do
    collection do
      get 'load_assigned_issues'
    end
  end
end
