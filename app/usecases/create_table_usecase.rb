class CreateTableUsecase
  include Usecase

  attr_reader :name

  def execute
    id = SecureRandom.uuid
    stream_name = "Table#{id}"
    repository = AggregateRoot::Repository.new
    repository.with_aggregate(Table.new(table_id: id, name: name), stream_name) do |table|
      table.create
    end

    id
  end
end
