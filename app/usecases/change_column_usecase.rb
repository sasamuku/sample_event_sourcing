class ChangeColumnUsecase
  include Usecase

  attr_reader :table_id
  attr_reader :column

  def execute
    stream_name = "Table#{table_id}"
    repository = AggregateRoot::Repository.new
    repository.with_aggregate(Table.new(table_id: table_id), stream_name) do |table|
      table.column_changed(name: column[:name], type: column[:type])
    end
  end
end
