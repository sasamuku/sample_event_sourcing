class Table
  include AggregateRoot

  attr_reader :table_id
  attr_reader :table_name
  attr_reader :synced

  def initialize(table_id: nil, table_name: nil)
    @synced = nil
    @table_id = table_id
    @table_name = table_name
  end

  def create
    apply Events::TableCreated.new(data: { table_id: table_id, table_name: table_name })
  end

  on Events::TableCreated do |event|
    @table_id = event.data.fetch(:table_id)
    @table_name = event.data.fetch(:table_name)
    @synced = false
  end
end
