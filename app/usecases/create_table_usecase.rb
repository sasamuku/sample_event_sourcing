class CreateTableUsecase
  include Usecase

  attr_reader :name

  def execute
    table_id = SecureRandom.uuid
    stream_name = "Table#{table_id}"
    repository = AggregateRoot::Repository.new
    repository.with_aggregate(Table.new(table_id: table_id, name: name), stream_name) do |table|
      table.create
    end

    table_id
  end
end
