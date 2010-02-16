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
  should_have_before_filter :check_for_no_projects

  context "GET to :index" do
    context "as a user without any projects" do
      setup do
        @user = User.generate_with_protected!
        @request.session[:user_id] = @user.id

        get :index
      end
      
      should_respond_with :success
      should_not_assign_to :time_entries
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

  context "POST to :save with valid params and a valid user" do
    setup do
      @project = Project.generate!
      @activity = TimeEntryActivity.generate!

      generate_user_and_login_for_project(@project)
      @issue = Issue.generate!(:project => @project, :tracker => @project.trackers.first, :priority => IssuePriority.generate!(:name => 'Low'))
    end

    should "save a new time entry" do

      assert_difference('TimeEntry.count',2) do
        post :save, :time_entries => {
          "1234" => {
            "comments" => 'a comment',
            "project_id" => @project.id,
            "issue_id" => @issue.id,
            "activity_id" => @activity.id,
            "spent_on" => Date.today.to_s,
            "hours" => '42'
          },
          "9658" => {
            "comments" => 'a comment',
            "project_id" => @project.id,
            "issue_id" => @issue.id,
            "activity_id" => @activity.id,
            "spent_on" => Date.today.to_s,
            "hours" => '42'
          }
        }
      end
      
    end

    should "replace the time entry form with a flash message" do
      post :save, :time_entries => {
        "1234" => {
          "comments" => 'a comment',
          "project_id" => @project.id,
          "issue_id" => @issue.id,
          "activity_id" => @activity.id,
          "spent_on" => Date.today.to_s,
          "hours" => '42'
        }
      }

      assert_select_rjs :replace_html, 'entry_1234', :text => /notice/
    end
  end

  context "POST to :save with invalid params and a valid user" do
    setup do
      @project = Project.generate!
      @activity = TimeEntryActivity.generate!

      generate_user_and_login_for_project(@project)
      @issue = Issue.generate!(:project => @project, :tracker => @project.trackers.first, :priority => IssuePriority.generate!(:name => 'Low'))
    end
    should "not save a time entry" do

      assert_no_difference('TimeEntry.count') do
        post :save, :time_entries => {
          "1234" => {
            "comments" => 'a comment',
            "project_id" => @project.id,
            "issue_id" => @issue.id,
            "activity_id" => @activity.id,
            "spent_on" => '',
            "hours" => '42'
          }
        }
      end
      
    end

    should "re-render the time entry from" do
      post :save, :time_entries => {
        "1234" => {
          "comments" => 'a comment',
          "project_id" => @project.id,
          "issue_id" => @issue.id,
          "activity_id" => @activity.id,
          "spent_on" => '',
          "hours" => '42'
        }
      }

      assert_select_rjs :replace, 'entry_1234', :text => /blank/
    end
  end
end
