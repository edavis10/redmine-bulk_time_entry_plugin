require 'fastercsv'

class BulkTimeEntry
  def self.import_from_csv(file)
    csv_file = File.read(file)
    row_counter = 0

    begin
      ActiveRecord::Base.transaction do
        FasterCSV.parse(csv_file) do |row|
          time = TimeEntry.new(:issue_id => row[0],
                               :comments => row[1].strip, # TODO: truncate
                               :spent_on => row[2],
                               :activity => TimeEntryActivity.find_by_name(row[3].strip),
                               :hours => row[4])
          time.user = User.find_by_login(row[5].strip)

          time.save!
          row_counter += 1
        end
      end
    rescue ActiveRecord::StatementInvalid, ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid => ex
      return "ERROR: #{ex.message}"
    end

    return "Imported #{row_counter} records"
  end
  
end
