class TablesController < ApplicationController
  def create
    id = CreateTableUsecase.new(name: params[:name]).execute

    render json: { status: :ok, order: { id: id } }
  end

  def delete
    DeleteTableUsecase.new(table_id: params[:table_id]).execute

    render json: { status: :ok }
  end
end
