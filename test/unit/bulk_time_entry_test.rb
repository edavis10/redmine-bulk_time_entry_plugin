require File.dirname(__FILE__) + '/../test_helper'

require 'fastercsv'

# Failing records are tested in BulkTimeEntryTransaction since Rails
# can't turn fixture transactions off for a single test case.
class BulkTimeEntryTest < ActiveSupport::TestCase
  include BulkTimeEntryTestHelper  

  context "#import_from_csv" do
    context "non-readable file" do
      setup do
        @file = '/a/test_file.csv'
      end

      should 'raise an exception' do
        assert_no_difference 'TimeEntry.count' do
          assert_raises Errno::ENOENT do
            BulkTimeEntry.import_from_csv(@file)
          end
        end
      end
    end

    context "unparsable file" do
      setup do
        @file = mock_csv_file('/csv/invalid.csv',
                              'This is not a csv file. "Nope"')
        
      end
      
      should 'raise an exception' do
        assert_no_difference 'TimeEntry.count' do
          assert_raises FasterCSV::MalformedCSVError do
            BulkTimeEntry.import_from_csv(@file.name)
          end
        end
      end
    end

    context "valid file" do

      should "skip empty lines" do
        @csv_data = generate_csv_data
        @csv_data << ['','','','','','']
        @file = mock_csv_file('/csv/valid.csv',
                              @csv_data.collect {|row| row.join(', ')}.join("\n"))

        assert_difference 'TimeEntry.count', 5 do
          BulkTimeEntry.import_from_csv(@file.name)
        end
        
      end

      should "skip invalid lines" do
        @csv_data = generate_csv_data
        @csv_data << ['','']
        @file = mock_csv_file('/csv/valid.csv',
                              @csv_data.collect {|row| row.join(', ')}.join("\n"))

        @response = ''
        assert_difference 'TimeEntry.count', 5 do
          @response = BulkTimeEntry.import_from_csv(@file.name)
        end
        assert_match /1 records failed to import/, @response
        
      end

      context "with valid imports" do
        setup do
          @csv_data = generate_csv_data
          @file = mock_csv_file('/csv/valid.csv',
                                @csv_data.collect {|row| row.join(', ')}.join("\n"))
        end

        should "import one record per line" do
          assert_difference 'TimeEntry.count', 5 do
            BulkTimeEntry.import_from_csv(@file.name)
          end
        end


        should 'create a TimeEntry record' do
          BulkTimeEntry.import_from_csv(@file.name)
          time_entry = TimeEntry.last
          last_csv_entry = @csv_data[-1]
          
          assert_equal last_csv_entry[0], time_entry.issue_id.to_s
          assert_equal last_csv_entry[1], time_entry.comments
          assert_equal last_csv_entry[2], time_entry.spent_on.to_s
          assert_equal last_csv_entry[3], time_entry.activity.name
          assert_equal last_csv_entry[4], time_entry.hours.to_s
          assert_equal last_csv_entry[5], time_entry.user.login
        end

        should 'truncate comments over 255 characters' do
          @csv_data << [
                       Issue.last.id.to_s,
                       'A' * 300,
                       Date.today.to_s,
                       @activity.name,
                       5,
                       @user.login
                      ]
          @file = mock_csv_file('/csv/valid.csv',
                                @csv_data.collect {|row| row.join(', ')}.join("\n"))

          BulkTimeEntry.import_from_csv(@file.name)
          time_entry = TimeEntry.last

          assert_match /AAA/, time_entry.comments
          assert_equal 255, time_entry.comments.length

        end
      end
    end
  end
end
