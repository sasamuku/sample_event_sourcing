class TablesController < ApplicationController
  def create
    id = CreateTableUsecase.new(name: params[:name]).execute

    render json: { status: :ok, table: { table_id: id } }
  end

  def delete
    DeleteTableUsecase.new(table_id: params[:table_id]).execute

    render json: { status: :ok }
  end

  def column
    # if intended to delete column, do not set type
    # ex. {"name": "column_name"}
    ChangeColumnUsecase.new(table_id: params[:table_id], column: params[:column].permit!).execute

    render json: { status: :ok }
  end

  def show
    id = params[:table_id]
    table = ShowTableUsecase.new(table_id: id).execute

    render json: {
      table: {
        table_id: id,
        name: table.name,
        synced: table.synced,
        exists: table.exists,
        columns: table.columns.transform_values(&:to_h)
      }
    }
  end
end
