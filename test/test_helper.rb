# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

Rails::Initializer.run do |config|
  config.gem "thoughtbot-shoulda", :lib => "shoulda", :source => "http://gems.github.com"
  config.gem "nofxx-object_daddy", :lib => "object_daddy", :source => "http://gems.github.com"
end

# TODO: The gem or official version of ObjectDaddy doesn't set protected attributes.
def User.generate_with_protected!(attributes={})
  user = User.spawn(attributes) do |user|
    user.login = User.next_login
    attributes.each do |attr,v|
      user.send("#{attr}=", v)
    end
  end
  user.save!
  user
end

# Helpers
class ActiveSupport::TestCase
end

module BulkTimeEntryTestHelper
  def mock_csv_file(name, data='')
    file = mock
    file.stubs(:name).returns(name)
    File.stubs(:read).with(name).returns(data)
    file
  end

  def generate_csv_data(count=5)
    @activity ||= TimeEntryActivity.generate!
    @user ||= User.generate_with_protected!

    @project ||= Project.generate!
    @tracker ||= Tracker.generate!
    @project.trackers << @tracker unless @project.trackers.include? @tracker

    csv_data = []
    5.times {
      issue = Issue.generate!(:tracker => @tracker, :project => @project)
      csv_data << [issue.id.to_s, 'A comment', Date.today.to_s, @activity.name, (rand * 10).round(2).to_s, @user.login]
          }
    csv_data
  end
end

# Shoulda
class ActiveSupport::TestCase
end
