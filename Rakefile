#!/usr/bin/env ruby
require 'redmine_plugin_support'

Dir[File.expand_path(File.dirname(__FILE__)) + "/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

RedminePluginSupport::Base.setup do |plugin|
  plugin.project_name = 'bulk_time_entry_plugin'
  plugin.default_task = [:test]
  plugin.tasks = [:doc, :release, :clean, :test, :db, :metrics]
  # TODO: gem not getting this automaticly
  plugin.redmine_root = File.expand_path(File.dirname(__FILE__) + '/../../../')
end
begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "bulk_time_entry_plugin"
    s.summary = "This is a plugin to enter multiple time entries at one time."
    s.email = "edavis@littlestreamsoftware.com"
    s.homepage = "https://projects.littlestreamsoftware.com/projects/redmine-bte"
    s.description = "This is a plugin to enter multiple time entries at one time."
    s.authors = ["Eric Davis"]
    s.rubyforge_project = "littlestream"
    s.files =  FileList[
                        "[A-Z]*",
                        "init.rb",
                        "rails/init.rb",
                        "{bin,generators,lib,test,app,assets,config,lang}/**/*",
                        'lib/jeweler/templates/.gitignore'
                       ]
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

