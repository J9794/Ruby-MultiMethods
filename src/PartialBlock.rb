class PartialBlock

  attr_reader :types, :block

  def initialize(types,&block)
    @types = types
    @block = block
  end

  def matches(*parameters)
    return false if parameters.size != types.size
    parameters.zip(types).all? do |parameter,type|
      parameter.is_a? type
    end
  end

  def call(*parameters)
    throw ArgumentError if !matches(*parameters)
    block.call(*parameters)
  end

end