class TablesController < ApplicationController
  def create
    id = CreateTableUsecase.new(table_name: params[:table_name]).execute

    render json: { status: :ok, order: { id: id } }
  end

  def delete
    DeleteTableUsecase.new(table_id: params[:table_id]).execute

    render json: { status: :ok }
  end
end
