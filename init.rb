# Empty redmine plguin
require 'redmine'

RAILS_DEFAULT_LOGGER.info 'Starting Bulk Time Entry Plugin for RedMine'

Redmine::Plugin.register :bulk_time_entry do
  name 'Bulk Time Entry'
  author 'Eric Davis'
  description 'This is a plugin to help enter multiple timelogs at one time'
  version '0.0.0'
end
