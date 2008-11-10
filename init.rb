require 'redmine'

Redmine::Plugin.register :bulk_time_entry_plugin do
  name 'Bulk Time Entry'
  author 'Eric Davis'
  description 'This is a plugin to enter multiple time entries at one time.'
  version '0.1.0'
  
  menu :top_menu, :bulk_time_entry, {:controller => "bulk_time_entries", :action => 'index'}, 
    :caption => :bulk_time_entry_title, :if => Proc.new{User.current.logged?} 
end
