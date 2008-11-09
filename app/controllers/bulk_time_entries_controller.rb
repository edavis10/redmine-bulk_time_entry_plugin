class BulkTimeEntriesController < ApplicationController
  unloadable
  layout 'base'
  before_filter :load_activities
  before_filter :load_allowed_projects
  
  def index
    @time_entries = [TimeEntry.new(:spent_on => Date.today, :hours=>nil)]

    if @projects.empty?
      render :action => 'no_projects'
    end
    load_current_user_project_issues_by_project(@projects.first.id)
  end
  
  def load_assigned_issues
    load_current_user_project_issues_by_project(params[:project_id])
    render(:update) do |page|
      page.replace_html params[:entry_id]+'_issues', :partial => 'issues_selector', :locals => { :issues => @issues, :rnd => params[:entry_id].split('_')[1]  }
    end
  end
  
  def save
    if request.post? 
      @time_entries = params[:time_entries]

      render :update do |page|
        @time_entries.each_pair do |html_id, entry|
          next unless BulkTimeEntriesController.allowed_project?(entry[:project_id])
          @time_entry = TimeEntry.new(entry)
          @time_entry.hours = nil if @time_entry.hours.blank? or @time_entry.hours <= 0
          @time_entry.project_id = entry[:project_id] # project_id is protected from mass assignment
          @time_entry.user = User.current
          unless @time_entry.save
            @issues = BulkTimeEntriesController.get_current_user_project_issues_by_project(@time_entry.project_id)
            page.replace "entry_#{html_id}", :partial => 'time_entry', :object => @time_entry
          else
            page.replace_html "entry_#{html_id}", "<div class='flash notice'>#{l(:text_time_added_to_project, @time_entry.hours.to_f)}#{" (#{@time_entry.comments})" unless @time_entry.comments.blank?}.</div>"
          end
        end
      end
    end    
  end
    
  def add_entry
    @time_entry = TimeEntry.new(:spent_on => Date.today, :hours=>nil)
    load_current_user_project_issues_by_project(@projects.first.id)
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
    @activities = Enumeration::get_values('ACTI')  
  end
  
  def load_allowed_projects
    @projects = User.current.projects.find(:all,
      Project.allowed_to_condition(User.current, :log_time), :include => :parent)
  end

  def load_current_user_project_issues_by_project(project_id)
    @issues = BulkTimeEntriesController.get_current_user_project_issues_by_project(project_id)
  end
  
  def self.get_current_user_project_issues_by_project(project_id)
    return Issue.find(:all, 
      :conditions => {:assigned_to_id => User.current.id, :project_id => project_id})
  end
  
  def self.allowed_project?(project_id)
    return User.current.projects.find_by_id(project_id, Project.allowed_to_condition(User.current, :log_time))
  end
end
