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

  def index
    @time_entries = [TimeEntry.new(:spent_on => today_with_time_zone.to_s)]
  end

  def load_assigned_issues
    @issues = get_issues(params[:project_id])
    @selected_project = BulkTimeEntriesController.allowed_project?(params[:project_id])
    @activities = @selected_project.present? ? @selected_project.activities : []
    @entry_id = params[:entry_id].to_s
    @rnd = @entry_id.split('_')[1]
    respond_to do |format|
      format.js {}
    end
  end

  def create
    @unsaved_entries = {}
    @saved_entries = {}

    params[:time_entries].each_pair do |html_id, entry|
      time_entry = TimeEntry.create_bulk_time_entry(entry)
      if time_entry.new_record?
        @unsaved_entries[html_id] = time_entry
      else
        @saved_entries[html_id] = time_entry
      end
    end unless params[:time_entries].blank?

    respond_to do |format|
      format.js {}
    end
  end

  def new
    spent_on = Date.parse(params[:date]) rescue nil
    spent_on ||= today_with_time_zone

    @time_entry = TimeEntry.new(:spent_on => spent_on.to_s)
    respond_to do |format|
      format.js {}
      format.html { redirect_to bulk_time_entries_path }
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

  # Returns the today's date using the User's time_zone
  #
  # @return [Date] today
  def today_with_time_zone
    time_proxy = Time.zone = User.current.time_zone
    time_proxy ||= Time # In case the user has no time_zone
    today = time_proxy.now.to_date
  end

  def self.allowed_project?(project_id)
    return User.current.projects.find_by_id(project_id, :conditions => Project.allowed_to_condition(User.current, :log_time))
  end
end
