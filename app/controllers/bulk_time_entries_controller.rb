class BulkTimeEntriesController < ApplicationController
  unloadable
  layout 'base'
  
  def index
    render :text => 'hi'
  end
end
