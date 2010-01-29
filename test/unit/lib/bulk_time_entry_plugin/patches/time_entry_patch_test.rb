require 'test_helper'

class BulkTimeEntryPlugin::Patches::TimeEntryPatchTest < ActiveSupport::TestCase
  context "TimeEntry#create_bulk_time_entry" do
    setup do
      User.current = @user = User.generate_with_protected!
      @project = Project.generate!
      @role = Role.generate!(:permissions => Redmine::AccessControl.permissions.collect(&:name))
      Member.generate!(:project => @project, :roles => [@role], :principal => @user)
      @valid_params = {:project_id => @project.id, :hours => 5, :activity_id => TimeEntryActivity.generate!.id, :spent_on => Date.today.to_s}
    end

    should "return the unsaved TimeEntry if the current user is not allowed to log time to the project" do
      @role.update_attributes(:permissions => [])

      assert_no_difference('TimeEntry.count') do
        @entry = TimeEntry.create_bulk_time_entry(@valid_params)
      end
      assert_equal false, @entry.valid?
    end
    
    context "saving a valid record" do
      should "save a new Time Entry record" do
        assert_difference('TimeEntry.count') do
          @entry = TimeEntry.create_bulk_time_entry(@valid_params)
        end

        assert @entry.is_a? TimeEntry
      end

      should "set the project of the new record" do
        @entry = TimeEntry.create_bulk_time_entry(@valid_params)
        assert_equal @project, @entry.project
      end

      should "assign the current user" do
        @entry = TimeEntry.create_bulk_time_entry(@valid_params)
        assert_equal @user, @entry.user
      end

      should "set hours to nil if they are passed in as 0" do
        @entry = TimeEntry.create_bulk_time_entry(@valid_params.merge(:hours => 0))
        assert_equal @user, @entry.user
      end
      
    end
    
  end
end
