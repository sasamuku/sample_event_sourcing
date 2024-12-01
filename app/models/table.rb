class Table
  include AggregateRoot
  class HasAlreadyBeenSynced < StandardError; end
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

  def confirm_created
    raise HasAlreadyBeenSynced if synced
    apply TableCreationConfirmed.new(data: { table_id: table_id })
  end

  def reject_created
    raise HasAlreadyBeenSynced if synced
    apply TableCreationRejected.new(data: { table_id: table_id })
  end

  def delete
    raise HasNotBeenSynced unless synced
    apply TableDeleted.new(data: { table_id: table_id })
  end

  on TableCreated do |event|
    @table_id = event.data.fetch(:table_id)
    @name = event.data.fetch(:name)
    @synced = false
  end

  on TableCreationConfirmed do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = true
  end

  on TableCreationRejected do |event|
    @table_id = event.data.fetch(:table_id)
    @deleted = true
  end

  on TableDeleted do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = false
    @deleted = true
  end
end
