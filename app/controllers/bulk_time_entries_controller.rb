class BulkTimeEntriesController < ApplicationController
  unloadable
  layout 'base'
  
  def index
    # TODO: Get list of projects user has permission
    # TODO: Check projects isn't empty
    @activities = Enumeration::get_values('ACTI')
    @projects = Project.find(:all) # TODO: Filter
    @time_entries = [TimeEntry.new, TimeEntry.new]
  end
  
  def save
    if request.post? 
      @time_entries = params[:time_entries]
      @time_entries.each do |entry|
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
end
