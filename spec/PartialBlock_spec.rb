require 'rspec'
require_relative '../src/PartialBlock'

describe 'Partial Block' do

  describe 'Matching' do

    describe 'Block which expects one String' do

      string_block = PartialBlock.new([String]) do |who|
        "Hello #{who}"
      end

      it 'should be true if the the parameter is a string' do
        expect(string_block.matches('a')).to be true
      end

      it 'should be false if there parameter is not a string' do
        expect(string_block.matches(1)).to be false
      end

      it 'should be false if the amount of parameters is different to 1' do
        expect(string_block.matches('a','b')).to be false
      end

    end

    describe 'Block which expects a Fixnum and an Array' do

      fixnum_and_array_block = PartialBlock.new([Fixnum,Array]) do |who|
        "Hello #{who}"
      end

      it 'should be true if the the parameters are a fixnum and an array (in that order)' do
        expect(fixnum_and_array_block.matches(6,[1,2,3])).to be true
      end

      it 'should be false if the parameters are an array and a fixnum' do
        expect(fixnum_and_array_block.matches([],0)).to be false
      end

      it 'should be false the amount of parameters is different to 2' do
        expect(fixnum_and_array_block.matches(10)).to be false
      end

    end

    describe 'Block with a module' do

      module A
      end

      a_block = PartialBlock.new([A]) do end

      class B
        include A
      end

      it 'should match with a class that includes its module' do
        expect(a_block.matches(B.new)).to be true
      end

      it 'should not match with a class that that does not include its module' do
        expect(a_block.matches(Object.new)).to be false
      end

    end

    describe 'Block with no classes/modules' do

      no_parameters_block = PartialBlock.new([]) do end

      it 'should match if called with no parameters' do
        expect(no_parameters_block .matches).to be true
      end

      it 'should not match if called with any parameters' do
        expect(no_parameters_block .matches(Object.new)).to be false
      end

    end

  end



  describe 'Call' do

    hello_world_block = PartialBlock.new([String]) do |string|
      'hello, ' + string + '!'
    end

    it 'should execute the block if the matching succeeded' do
      expect(hello_world_block.call('world')).to eq 'hello, world!'
    end

    it 'should throw ArgumentError if matching did not succeed' do
      expect{hello_world_block.call(10)}.to raise_error ArgumentError
    end

  end

end