class Array
  def sum(&block)
    self.inject(0) do |seed, element| seed + block.call(element) end
  end
end

class PartialBlock

  attr_reader :types, :block

  def initialize(types,&block)
    @types = types
    @block = block
  end

  def matches(*parameters)
    matches_type(*parameters.map {|p| p.class})
  end

  def matches_type(*parameter_types)
    return false if parameter_types.size != types.size
    parameter_types.zip(types).all? do |parameter_type,type|
      parameter_type <= type
    end
  end

  def call(*parameters)
    throw ArgumentError if !matches(*parameters)
    block.call(*parameters)
  end

  def parameters_distance(*parameters)
    parameter_distance = proc do |type,parameter| parameter.class.ancestors.index(type) end
    @types.zip(parameters).sum do |type,parameter| parameter_distance.call(type,parameter) end
  end

end