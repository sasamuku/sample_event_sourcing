class DeleteTableUsecase
  include Usecase

  attr_reader :table_id

  def execute
    stream_name = "Table#{table_id}"
    repository = AggregateRoot::Repository.new
    repository.with_aggregate(Table.new, stream_name) do |table|
      table.delete
    end
  end
end
