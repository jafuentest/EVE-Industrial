module CSVImportable
  extend ActiveSupport::Concern

  class_methods do
    def import_from_csv(path_to_csv_file)
      require 'csv'

      delete_all

      table = CSV.read(path_to_csv_file, headers: true)

      insert_all! table.map { |row| self.hash_from_csv_row(row) }
    rescue => ex
      "#{ex.class} -> #{ex.message}"
    end
  end
end
