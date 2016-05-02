require_relative '../src/PartialBlock'

class MultiMethods
end

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

  def self.included(includer)
    includer.extend ClassPart
    includer.instance_eval do
      behavior_provider = self
      partial_def(:respond_to?, [Object]) do
        raise SuperMethodException
      end
      partial_def(:respond_to?, [Object, Object]) do
        raise SuperMethodException
      end
      partial_def(:respond_to?, [Object, Object, Object]) do |sym, is_private, types|
        behavior_provider.is_multimethod?(sym) && respond_to?(sym, is_private) && behavior_provider.multimethod(sym).any? { |partial_block| partial_block.matches_type(*types) }
      end
    end
  end


  module ClassPart

    attr_writer :multi_methods_hash

    def multi_methods_hash
      @multi_methods_hash ||= {}
      if(superclass <= PartialDefinable)
        superclass.multi_methods_hash.merge @multi_methods_hash
      else
        @multi_methods_hash
      end
    end


    def partial_def (symbol, types_list, &block)
      @multi_methods_hash ||= {}
      @multi_methods_hash[symbol] ||= []
      multi_methods_hash[symbol] << (PartialBlock.new types_list, &block)
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
      possible_methods = @multi_methods_hash[symbol].select do |multi_method|
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

  module InstancePart

  end

end