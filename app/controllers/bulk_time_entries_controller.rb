# -*- coding: utf-8 -*-
class BulkTimeEntriesController < ApplicationController
  unloadable
  layout 'base'
  before_filter :load_activities
  before_filter :load_allowed_projects

  helper :custom_fields
  include BulkTimeEntriesHelper

  protect_from_forgery :only => [:index, :save]
  
  def index
    @time_entries = [TimeEntry.new(:spent_on => Date.today.to_s)]

    if @projects.empty?
      render :action => 'no_projects'
    end
  end

  def load_assigned_issues
    @issues = get_issues(params[:project_id])
    render(:update) do |page|
      page.replace_html params[:entry_id]+'_issues', :partial => 'issues_selector', :locals => { :issues => @issues, :rnd => params[:entry_id].split('_')[1]  }
    end
  end
  
  
  def save
    if request.post? 
      @time_entries = params[:time_entries]

      render :update do |page|
        @time_entries.each_pair do |html_id, entry|
          @time_entry = TimeEntry.create_bulk_time_entry(entry)
          if @time_entry.new_record?
            page.replace "entry_#{html_id}", :partial => 'time_entry', :object => @time_entry
          else
            time_entry_target = if @time_entry.issue
                                  "#{h(@time_entry.project.name)} - #{h(@time_entry.issue.subject)}"
                                else
                                  "#{h(@time_entry.project.name)}"
                                end
            page.replace_html "entry_#{html_id}", "<div class='flash notice'>#{l(:text_time_added_to_project, :count => @time_entry.hours, :target => time_entry_target)}#{" (#{@time_entry.comments})" unless @time_entry.comments.blank?}.</div>"
          end
        end
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

  def self.allowed_project?(project_id)
    return User.current.projects.find_by_id(project_id, :conditions => Project.allowed_to_condition(User.current, :log_time))
  end
end
