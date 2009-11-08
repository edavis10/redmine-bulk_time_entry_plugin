require File.dirname(__FILE__) + '/../test_helper'

require 'fastercsv'

class BulkTimeEntryTransactionTest < ActiveSupport::TestCase
  include BulkTimeEntryTestHelper
  self.use_transactional_fixtures = false # using transactions in code

  # Need to purge data since it's not in a test transaction
  def self.purge_data
    User.delete_all
    Project.delete_all
    Tracker.delete_all
    Issue.delete_all
    IssueStatus.delete_all
    IssuePriority.delete_all
    TimeEntry.delete_all
    TimeEntryActivity.delete_all
  end
  
  setup do
    purge_data
  end
  
  context "#import_from_csv" do
    context "with a failing record" do
      setup do
        @csv_data = generate_csv_data
        @csv_data << ['1500','No issue',Date.today.to_s, @activity.name, 4.5, @user.login]

        @file = mock_csv_file('/csv/missing_issue_id.csv',
                              @csv_data.collect {|row| row.join(', ')}.join("\n"))
      end

      should "rollback the import if any record fails" do
        assert_no_difference 'TimeEntry.count' do
          BulkTimeEntry.import_from_csv(@file.name)
        end
      end

      should "return the exception's message" do
        message = BulkTimeEntry.import_from_csv(@file.name)
        assert_match /validation failed/i, message
      end

      should "include ERROR in the exception's message" do
        message = BulkTimeEntry.import_from_csv(@file.name)
        assert_match /ERROR/i, message
      end
    end
  end
end
