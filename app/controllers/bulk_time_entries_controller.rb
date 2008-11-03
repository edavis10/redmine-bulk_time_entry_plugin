class BulkTimeEntriesController < ApplicationController
  unloadable
  layout 'base'
  before_filter :load_activities
  before_filter :load_allowed_projects
  
  def index
    @time_entries = [TimeEntry.new(:spent_on => Date.today.to_s)]

    if @projects.empty?
      render :action => 'no_projects'
    end
  end
  
  def save
    if request.post? 
      @time_entries = params[:time_entries]

      render :update do |page|
        @time_entries.each_pair do |html_id, entry|
          next unless BulkTimeEntriesController.allowed_project?(entry[:project_id])
          @time_entry = TimeEntry.new(entry)
          @time_entry.project_id = entry[:project_id] # project_id is protected from mass assignment
          @time_entry.user = User.current
          unless @time_entry.save
            page.replace "entry_#{html_id}", :partial => 'time_entry', :object => @time_entry
          else
            page.replace_html "entry_#{html_id}", "<div class='flash notice'>#{l(:text_time_added_to_project,@time_entry.hours)}#{" (#{@time_entry.comments})" unless @time_entry.comments.blank?}.</div>"
          end
        end
      end
    end    
  end
    
  def add_entry
    @time_entry = TimeEntry.new(:spent_on => Date.today.to_s)
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
  
  def self.allowed_project?(project_id)
    return User.current.projects.find_by_id(project_id, Project.allowed_to_condition(User.current, :log_time))
  end
end
