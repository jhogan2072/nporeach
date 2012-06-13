class CsvController < ApplicationController
  require 'csv'
  before_filter :authenticate_user!
  layout 'hybrid'
  
  def import
  end

  def upload
    table = ImportTable.new :original_path => params[:upload][:csv].original_filename
    row_index = 0
    file_data = params[:upload][:csv]
    if file_data.respond_to?(:read)
      file_contents = file_data.read
    elsif file_data.respond_to?(:path)
      file_contents = File.read(file_data.path)
    else
      logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
    end
    csv = CSV.parse(file_contents, :headers => true)
    csv.each do |row|
      column_index = 0
      row.each do |cell|
        table.import_cells.build :column_index => column_index, :row_index => row_index, :contents => cell
        column_index += 1
      end
      row_index += 1
    end
    table.save
    redirect_to import_table_path(table)
  end

end
