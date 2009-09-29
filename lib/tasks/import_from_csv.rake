namespace :bulk_time_entry do
  namespace :import do

    desc "Import mutiple time entries from a CSV file"
    task :csv => [:environment] do
      csv_file = ENV['CSV_FILE'] || File.join(RAILS_ROOT, 'time_entries.csv')

      puts BulkTimeEntry.import_from_csv(csv_file)
    end
    
  end
end
