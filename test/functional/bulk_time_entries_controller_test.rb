require 'test_helper'

class BulkTimeEntriesControllerTest < ActionController::TestCase
  context "routing" do
    should_route :get, "/bulk_time_entries", { :action => :index }
    should_route :post, "/bulk_time_entries/save", { :action => :save }
    should_route :post, "/bulk_time_entries/load_assigned_issues", { :action => :load_assigned_issues }
    should_route :post, "/bulk_time_entries/add_entry", { :action => :add_entry }
  end

end
