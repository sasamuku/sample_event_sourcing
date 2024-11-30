class Table
  include AggregateRoot
  class HasNotBeenSynced < StandardError; end

  attr_reader :table_id
  attr_reader :table_name
  attr_reader :synced
  attr_reader :deleted

  def initialize(table_id: nil, table_name: nil)
    @synced = nil
    @deleted = false
    @table_id = table_id
    @table_name = table_name
  end

  def create
    apply Events::TableCreated.new(data: { table_id: table_id, table_name: table_name })
  end

  def delete
    # raise HasNotBeenSynced unless synced
    apply Events::TableDeleted.new(data: { table_id: table_id })
  end

  on Events::TableCreated do |event|
    @table_id = event.data.fetch(:table_id)
    @table_name = event.data.fetch(:table_name)
    @synced = false
  end

  on Events::TableDeleted do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = false
    @deleted = true
  end
end
