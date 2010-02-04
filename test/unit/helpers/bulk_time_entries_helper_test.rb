require File.dirname(__FILE__) + '/../../test_helper'

class BulkTimeEntriesHelperTest < HelperTestCase
  include ApplicationHelper
  include BulkTimeEntriesHelper
  include ActionController::Assertions::SelectorAssertions

  # Used by assert_select
  def html_document
    HTML::Document.new(@response.body)
  end

  def setup
    @response = ActionController::TestResponse.new
    super
  end

  context "#grouped_options_for_issues" do
    setup do
      @project = Project.generate!
    end

    context "with no issues" do
      should "return an empty option" do
        @response.body = grouped_options_for_issues([])
        assert_select 'option', :text => ''
      end
    end

    context "with issues" do
      setup do
        closed = IssueStatus.generate!(:is_closed => true)
        @issues = [
                   Issue.generate_for_project!(@project, :tracker => @project.trackers.first),
                   Issue.generate_for_project!(@project, :tracker => @project.trackers.first, :status => closed),
                   Issue.generate_for_project!(@project, :tracker => @project.trackers.first),
                   Issue.generate_for_project!(@project, :tracker => @project.trackers.first)
                  ]
        @response.body = grouped_options_for_issues(@issues)
      end

      should 'render an option tag per issue plan a blank one' do
        assert_select 'option', :count => 5
      end

      should 'group the open issues with the Open Issues label' do
        assert_select 'optgroup[label=?]', l(:label_open_issues) do
          assert_select 'option', :count => 3
        end
      end

      should 'group the closed issues with the Closed Issues label' do
        assert_select 'optgroup[label=?]', l(:label_closed_issues) do
          assert_select 'option', :count => 1
        end
      end
    end
  end

  context "#get_issues" do
    context "as a user without any projects" do
      should "be empty" do
        @user = User.generate_with_protected!
        User.current = @user
        @project = Project.generate!
        Issue.generate_for_project!(@project)
        Issue.generate_for_project!(@project)
        
        assert get_issues(@project.id).empty?
      end
    end

    context "as a user with a project" do
      should "return the project's issues" do
        @project = Project.generate!
        generate_user_and_login_for_project(@project)
        User.current = @user
        issue1 = Issue.generate_for_project!(@project)
        issue2 = Issue.generate_for_project!(@project)

        result = get_issues(@project.id)
        assert_equal 2, result.size
        assert result.include? issue1
        assert result.include? issue2
      end
    end
  end
end
