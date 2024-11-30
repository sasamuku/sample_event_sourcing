class ShowTableUsecase
  include Usecase

  attr_reader :table_id

  def execute
    stream_name = "Table#{table_id}"
    repository = AggregateRoot::Repository.new
    repository.load(Table.new, stream_name)
  end
end
