class ImportTablesController < InheritedResources::Base
  before_filter :authenticate_user!

  def show
    @import_table = ImportTable.find(params[:id])
    @import_cells = @import_table.import_cells
    @row_index_max = @import_cells.map { |cell| cell.row_index }.max
    @column_index_max = @import_cells.map { |cell| cell.column_index }.max
    show!
  end
end
