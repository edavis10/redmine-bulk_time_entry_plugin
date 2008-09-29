class BulkTimeEntriesController < ApplicationController
  unloadable
  layout 'base'
  before_filter :set_activities, :except => :save
  before_filter :allowed_projects, :except => :save
  
  def index
    #@projects = allowed_projects
    @time_entries = [TimeEntry.new]

    if @projects.empty?
      render :action => 'no_projects'
    end
  end
  
  def save
    if request.post? 
      @time_entries = params[:time_entries]
      @time_entries.each do |entry|
        next unless allowed_project?(entry[:project_id])
        
        @time_entry = TimeEntry.new(entry)
        @time_entry.project_id = entry[:project_id] # project_id is protected from mass assignment
        @time_entry.user = User.current
        # TODO: Display saved state in flash like bulk issue edit
        @time_entry.save

      end
      flash[:notice] = l(:notice_successful_update)
    end    
    redirect_to :action => 'index'
  end
  
  def entry_form
    #@projects = allowed_projects
    @time_entry = TimeEntry.new
    respond_to do |format|
      format.js {  render :action => 'entry_form.js.rjs' }
    end
  end
  
  private

  def set_activities
    @activities = Enumeration::get_values('ACTI')    
  end
  
  def allowed_projects
    @projects = User.current.projects.find(:all, Project.allowed_to_condition(User.current, :log_time))
  end
  
  def allowed_project?(project_id)
    return User.current.projects.find_by_id(project_id, Project.allowed_to_condition(User.current, :log_time))
  end
end
