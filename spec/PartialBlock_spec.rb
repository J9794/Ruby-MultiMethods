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

      string_block = PartialBlock.new([Fixnum,Array]) do |who|
        "Hello #{who}"
      end

      it 'should be true if the the parameters are a fixnum and an array (in that order)' do
        expect(string_block.matches(6,[1,2,3])).to be true
      end

      it 'should be false if the parameters are an array and a fixnum' do
        expect(string_block.matches([],0)).to be false
      end

      it 'should be false the amount of parameters is different to 2' do
        expect(string_block.matches(10)).to be false
      end

    end

  end

end