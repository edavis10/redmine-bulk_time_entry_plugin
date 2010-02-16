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
    render(:update) do |page|
      page.replace_html params[:entry_id]+'_issues', :partial => 'issues_selector', :locals => { :issues => @issues, :rnd => params[:entry_id].split('_')[1]  }
      page.replace_html params[:entry_id]+'_activities', :partial => 'activities_selector', :locals => { :rnd => params[:entry_id].split('_')[1], :activities => (@selected_project.present? ? @selected_project.activities : [])  }
    end
  end
  
  
  def save
    if request.post? 
      @time_entries = params[:time_entries]
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
      format.js do
        render :update do |page| 
          page.insert_html :bottom, 'entries', :partial => 'time_entry', :object => @time_entry
        end
      end
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
