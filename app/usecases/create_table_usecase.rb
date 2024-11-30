class CreateTableUsecase
  include Usecase

  attr_reader :table_name

  def execute
    id = SecureRandom.uuid
    stream_name = "Table#{id}"
    repository = AggregateRoot::Repository.new
    repository.with_aggregate(Table.new(table_id: id, table_name: table_name), stream_name) do |table|
      table.create
    end

    id
  end
end
