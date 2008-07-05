class BulkTimeEntriesController < ApplicationController
  unloadable
  layout 'base'
  
  def index
    @activities = Enumeration::get_values('ACTI')
    @projects = User.current.projects.find(:all, Project.allowed_to_condition(User.current, :log_time))

    if @projects.empty?
      render :action => 'no_projects'
    end
    @time_entries = [TimeEntry.new]
  end
  
  def save
    if request.post? 
      @time_entries = params[:time_entries]
      @time_entries.each do |entry|
        @time_entry = TimeEntry.new(entry)
        # TODO: Verify user has permissions for project
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
    @activities = Enumeration::get_values('ACTI')
    @projects = User.current.projects.find(:all, Project.allowed_to_condition(User.current, :log_time))
    @time_entry = TimeEntry.new
    respond_to do |format|
      format.js {  render :action => 'entry_form.js.rjs' }
    end
  end
end
