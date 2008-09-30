# Empty redmine plguin
require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting Bulk Time Entry Plugin for RedMine'

Redmine::Plugin.register :bulk_time_entry_plugin do
  name 'Bulk Time Entry'
  author 'Eric Davis'
  description 'This is a plugin to help enter multiple timelogs at one time'
  version '0.0.0'
  
  menu :top_menu, :bulk_time_entry, {:controller => "bulk_time_entries", :action => 'index'}, 
    :caption => :bulk_time_entry_title, :if => Proc.new{User.current.logged?} 
end
