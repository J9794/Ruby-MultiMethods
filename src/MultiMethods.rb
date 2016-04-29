require_relative '../src/PartialBlock'

class MultiMethods
end

module PartialDefinable

  def partial_def (symbol, types_list, &block)
    @multi_methods_hash ||= {}
    @multi_methods_hash[symbol] ||= []
    @multi_methods_hash[symbol] << (PartialBlock.new types_list,&block)
    self.send(:define_method,symbol) do |*parameters|
      self.class.call_multi_method(symbol, *parameters)
    end
  end

  def best_multi_method (symbol, *parameters)
    possible_methods = @multi_methods_hash[symbol].select do |multi_method|
      multi_method.matches(*parameters)
    end
    throw ArgumentError if possible_methods.empty?
    possible_methods.min_by do |multi_method|
      multi_method.parameters_distance(*parameters)
    end
  end

  def call_multi_method (symbol, *parameters)
    best_multi_method(symbol, *parameters).call(*parameters)
  end

  def multimethods
    @multi_methods_hash.keys
  end

  def multimethod(sym)
    @multi_methods_hash[sym]
  end

end