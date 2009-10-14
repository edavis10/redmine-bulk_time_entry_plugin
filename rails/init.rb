require 'redmine'

config.gem 'fastercsv'

if Rails.env == "test"
  
  # Bootstrap ObjectDaddy since it's needs to load before the Models
  # (it hooks into ActiveRecord::Base.inherited)
  require 'object_daddy'

  # Use the plugin's exemplar_path :nodoc:
  module ::ObjectDaddy
    module RailsClassMethods
      def exemplar_path
        File.join(File.dirname(__FILE__), 'test', 'exemplars')
      end
    end
  end
end


Redmine::Plugin.register :bulk_time_entry_plugin do
  name 'Bulk Time Entry'
  author 'Eric Davis'
  description 'This is a plugin to enter multiple time entries at one time.'
  version '0.3.0'
  
  menu :top_menu, :bulk_time_entry, {:controller => "bulk_time_entries", :action => 'index'}, 
    :caption => :bulk_time_entry_title, :if => Proc.new{User.current.allowed_to?(:log_time, nil, :global => true)} 
end
