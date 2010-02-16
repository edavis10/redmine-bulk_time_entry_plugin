require 'test_helper'

class BulkTimeEntriesControllerTest < ActionController::TestCase
  context "routing" do
    should_route :get, "/bulk_time_entries", { :action => :index }
    should_route :post, "/bulk_time_entries/save", { :action => :save }
    should_route :post, "/bulk_time_entries/load_assigned_issues", { :action => :load_assigned_issues }
    should_route :post, "/bulk_time_entries/add_entry", { :action => :add_entry }
  end

  should_have_before_filter :load_activities
  should_have_before_filter :load_allowed_projects
  should_have_before_filter :load_first_project

  context "GET to :index" do
    context "as a user without any projects" do
      setup do
        @user = User.generate_with_protected!
        @request.session[:user_id] = @user.id

        get :index
      end
      
      should_respond_with :success
      should_assign_to :time_entries
      should_assign_to :projects
      should_render_template :no_projects

    end

    context "as a user with projects" do
      setup do
        @project = Project.generate!
        generate_user_and_login_for_project(@project)

        get :index
      end
      
      should_respond_with :success
      should_assign_to :time_entries
      should_assign_to :projects
      should_assign_to :first_project
      should_render_template :index
    end
  end
end
