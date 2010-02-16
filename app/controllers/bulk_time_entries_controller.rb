# -*- coding: utf-8 -*-
class BulkTimeEntriesController < ApplicationController
  unloadable
  layout 'base'
  before_filter :load_activities
  before_filter :load_allowed_projects
  before_filter :load_first_project
  before_filter :check_for_no_projects

  helper :custom_fields
  include BulkTimeEntriesHelper

  protect_from_forgery :only => [:index, :save]
  
  def index
    @time_entries = [TimeEntry.new(:spent_on => Date.today.to_s)]
  end

  def load_assigned_issues
    @issues = get_issues(params[:project_id])
    @selected_project = BulkTimeEntriesController.allowed_project?(params[:project_id])
    respond_to do |format|
      format.js {}
    end
  end
  
  
  def save
    if request.post? 
      @unsaved_entries = {}
      @saved_entries = {}

      params[:time_entries].each_pair do |html_id, entry|
        time_entry = TimeEntry.create_bulk_time_entry(entry)
        if time_entry.new_record?
          @unsaved_entries[html_id] = time_entry
        else
          @saved_entries[html_id] = time_entry
        end
      end
      
      respond_to do |format|
        format.js {}
      end
    end
  end
    
  def add_entry
    begin
      spent_on = Date.parse(params[:date])
    rescue ArgumentError
      # Fall through
    end
    spent_on ||= Date.today
    
    @time_entry = TimeEntry.new(:spent_on => spent_on.to_s)
    respond_to do |format|
      format.js {}
    end
  end
  
  private

  def load_activities
    @activities = TimeEntryActivity.all
  end
  
  def load_allowed_projects
    @projects = User.current.projects.find(:all,
      Project.allowed_to_condition(User.current, :log_time))
  end

  def load_first_project
    @first_project = @projects.sort_by(&:lft).first unless @projects.empty?
  end

  def check_for_no_projects
    if @projects.empty?
      render :action => 'no_projects'
      return false
    end
  end

  def self.allowed_project?(project_id)
    return User.current.projects.find_by_id(project_id, :conditions => Project.allowed_to_condition(User.current, :log_time))
  end
end
