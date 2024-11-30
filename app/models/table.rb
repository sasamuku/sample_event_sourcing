class Table
  include AggregateRoot
  class HasNotBeenSynced < StandardError; end

  attr_reader :table_id
  attr_reader :name
  attr_reader :synced
  attr_reader :deleted

  def initialize(table_id: nil, name: nil)
    @synced = nil
    @deleted = false
    @table_id = table_id
    @name = name
  end

  def create
    apply TableCreated.new(data: { table_id: table_id, name: name })
  end

  def delete
    # raise HasNotBeenSynced unless synced
    apply TableDeleted.new(data: { table_id: table_id })
  end

  on TableCreated do |event|
    @table_id = event.data.fetch(:table_id)
    @name = event.data.fetch(:name)
    @synced = false
  end

  on TableDeleted do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = false
    @deleted = true
  end
end
