class Column
  attr_reader :name
  attr_reader :type
  attr_reader :nullable
  attr_reader :default
  attr_reader :primary_key

  def initialize(name:, type:, nullable: true, default: nil, primary_key: false)
    @name = name.to_sym
    @type = type.to_s
    @nullable = nullable
    @default = default
    @primary_key = primary_key
  end

  def to_h
    {
      name: name,
      type: type,
      nullable: nullable,
      default: default,
      primary_key: primary_key
    }
  end

  def ==(other)
    to_h == other.to_h
  end
end
