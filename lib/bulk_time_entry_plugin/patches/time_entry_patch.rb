module BulkTimeEntryPlugin
  module Patches
    module TimeEntryPatch
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods

        def create_bulk_time_entry(entry)
          return false unless BulkTimeEntriesController.allowed_project?(entry[:project_id])
          time_entry = TimeEntry.new(entry)
          time_entry.hours = nil if time_entry.hours.blank? or time_entry.hours <= 0
          time_entry.project_id = entry[:project_id] # project_id is protected from mass assignment
          time_entry.user = User.current
          time_entry
        end
        
      end
      
    end
  end
end
