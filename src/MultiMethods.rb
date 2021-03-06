require_relative '../src/PartialBlock'

class SuperMethodException < Exception
  attr_accessor :block

  def initialize(&block)
    if block_given?
      @block = block
    else
      @block = proc do |result|
        result
      end
    end
  end
end

module PartialDefinable

  def self.extended(extender)
    extender.extend ClassPart
    extender.singleton_class.include PartialDefinable
    extender.define_singleton_method(:partial_def) do |symbol, types_list, &block| singleton_class.partial_def(symbol, types_list, &block) end
  end

  def self.included(includer)
    includer.extend ClassPart
    includer.instance_eval do
      partial_def(:respond_to?, [Object]) do
        raise SuperMethodException
      end
      partial_def(:respond_to?, [Object, Object]) do
        raise SuperMethodException
      end
      partial_def(:respond_to?, [Object, Object, Object]) do |sym, is_private, types|
        singleton_class.is_multimethod?(sym) && respond_to?(sym, is_private)&& singleton_class.multimethod(sym).any? { |partial_block|
          partial_block.matches_type(*types) }
      end
    end
  end


  module ClassPart

    attr_writer :multi_methods_hash

    def multi_methods_hash
      @multi_methods_hash ||= {}
      return @multi_methods_hash unless superclass <= PartialDefinable
      inherited_multimethods = superclass.multi_methods_hash
      multimethod_symbols = (@multi_methods_hash.keys + inherited_multimethods.keys).uniq
      multimethod_symbols.map do |sym|
        inherited_partial_blocks = inherited_multimethods[sym] || []
        own_partial_blocks = @multi_methods_hash[sym] || []
        resulting_blocks = own_partial_blocks + inherited_partial_blocks.reject do |pb|
          own_partial_blocks.any? { |new_pb| new_pb.same_signature? pb }
        end
        {sym => resulting_blocks}
      end.reduce(:merge)
    end


    def partial_def (symbol, types_list, &block)
      @multi_methods_hash ||= {}
      @multi_methods_hash[symbol] ||= []
      @multi_methods_hash[symbol] << (PartialBlock.new types_list, &block)
      behavior_provider = self
      self.send(:define_method, symbol) do |*parameters|
        begin
          behavior_provider.call_multi_method(symbol, self, *parameters)
        rescue SuperMethodException => sup
          instance_exec super(*parameters), &sup.block
        end
      end
    end

    def best_multi_method (symbol, *parameters)
      possible_methods = multi_methods_hash[symbol].select do |multi_method|
        multi_method.matches(*parameters)
      end
      throw ArgumentError if possible_methods.empty?
      possible_methods.min_by do |multi_method|
        multi_method.parameters_distance(*parameters)
      end
    end

    def call_multi_method (symbol, instance, *parameters)
      instance.instance_exec *parameters, &best_multi_method(symbol, *parameters).block
    end

    def multimethods
      multi_methods_hash.keys
    end

    def multimethod(sym)
      multi_methods_hash[sym]
    end

    def is_multimethod?(sym)
      multimethods.include? sym
    end
  end

end