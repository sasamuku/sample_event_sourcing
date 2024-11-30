class TablesController < ApplicationController
  def create
    if params[:table_name].blank?
      render json: { error: "Table name must be provided" }, status: :bad_request
      return
    end

    id = CreateTableUsecase.new(table_name: params[:table_name]).execute

    render json: { status: :ok, order: { id: id } }
  end
end
