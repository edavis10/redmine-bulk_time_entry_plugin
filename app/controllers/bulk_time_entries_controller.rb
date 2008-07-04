class BulkTimeEntriesController < ApplicationController
  unloadable
  layout 'base'
  
  def index
    # TODO: Get list of projects user has permission
    # TODO: Check projects isn't empty
    @activities = Enumeration::get_values('ACTI')
    @time_entries = []
  end
  
  def save
    flash[:notice] = 'Redirected'
    redirect_to :action => 'index'
  end
end
