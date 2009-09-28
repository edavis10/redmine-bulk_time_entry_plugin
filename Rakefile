#!/usr/bin/env ruby
require 'redmine_plugin_support'

Dir[File.expand_path(File.dirname(__FILE__)) + "/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

RedminePluginSupport::Base.setup do |plugin|
  plugin.project_name = 'bulk_time_entry_plugin'
  plugin.default_task = [:test]
  plugin.tasks = [:doc, :release, :clean, :test]
  # TODO: gem not getting this automaticly
  plugin.redmine_root = File.expand_path(File.dirname(__FILE__) + '/../../../')
end
