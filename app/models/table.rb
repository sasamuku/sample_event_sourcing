class Table
  include AggregateRoot
  class HasAlreadyBeenSynced < StandardError; end
  class HasNotBeenSynced < StandardError; end

  attr_reader :table_id
  attr_reader :name
  attr_reader :synced
  attr_reader :exists
  attr_reader :error
  attr_reader :columns
  attr_reader :pending_column

  DEFAULT_COLUMNS = {
    id: Column.new(name: :id, type: "integer", nullable: false, primary_key: true),
    name: Column.new(name: :name, type: "text"),
    created_at: Column.new(name: :created_at, type: "timestamp"),
    updated_at: Column.new(name: :updated_at, type: "timestamp")
  }

  def initialize(table_id: nil, name: nil)
    @synced = nil
    @exists = false
    @table_id = table_id
    @name = name
    @columns = DEFAULT_COLUMNS.dup
    @pending_column = {}
  end

  def create
    apply TableCreated.new(data: { table_id: table_id, name: name, columns: columns.transform_values(&:to_h) })
  end

  def confirm_created
    raise HasAlreadyBeenSynced if synced
    apply TableCreationConfirmed.new(data: { table_id: table_id })
  end

  def reject_created
    raise HasAlreadyBeenSynced if synced
    apply TableCreationRejected.new(data: { table_id: table_id })
  end

  def column_changed(name:, type: nil, **options)
    raise HasNotBeenSynced unless synced
    # if deleted column, set type to nil
    column = type ? Column.new(name: name, type: type, **options) : nil
    apply TableChanged.new(data: {
      table_id: table_id,
      columns: { name => column&.to_h }
    })
  end

  def confirm_column_changed
    raise HasAlreadyBeenSynced if synced
    apply TableChangeConfirmed.new(data: { table_id: table_id })
  end

  def reject_column_changed
    raise HasAlreadyBeenSynced if synced
    apply TableChangeRejected.new(data: { table_id: table_id })
  end

  def delete
    raise HasNotBeenSynced unless synced
    apply TableDeleted.new(data: { table_id: table_id })
  end

  def confirm_deleted
    raise HasAlreadyBeenSynced if synced
    apply TableDeletionConfirmed.new(data: { table_id: table_id })
  end

  def reject_deleted
    raise HasAlreadyBeenSynced if synced
    apply TableDeletionRejected.new(data: { table_id: table_id })
  end

  on TableCreated do |event|
    @table_id = event.data.fetch(:table_id)
    @name = event.data.fetch(:name)
    @columns = event.data.fetch(:columns).transform_values do |column|
      Column.new(**column)
    end
    @synced = false
  end

  on TableCreationConfirmed do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = true
    @exists = true
  end

  on TableCreationRejected do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = true
    @exists = false
    @error = "Table creation rejected"
  end

  on TableChanged do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = false
    event.data.fetch(:columns).each do |name, column_data|
      name = name.to_sym
      @pending_column[name] = column_data ? Column.new(**column_data) : nil
    end
  end

  on TableChangeConfirmed do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = true
    @columns.merge!(pending_column)
    @pending_column = {}
  end

  on TableChangeRejected do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = true
    @columns.delete(pending_column.keys.first.to_sym)
    @pending_column = {}
  end

  on TableDeleted do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = false
  end

  on TableDeletionConfirmed do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = true
    @exists = false
  end

  on TableDeletionRejected do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = true
    @exists = true
    @error = "Table deletion rejected"
  end
end
