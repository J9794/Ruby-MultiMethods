require 'rspec'
require_relative '../src/MultiMethods'

describe 'MultiMethods' do

  class A
    singleton_class.include PartialDefinable
    partial_def :concat, [String, String] do |s1,s2|
      s1 + s2
    end

    partial_def :concat, [String, Integer] do |s1,n|
      s1 * n
    end

    partial_def :concat, [Array] do |a|
      a.join
    end

    partial_def :concat, [Object, Object] do |_ , _|
      'Objetos concatenados'
    end

  end

  describe 'Calling the methods' do


    it 'should choose the correct and closest method to execute' do
      expect(A.new.concat('hello', ' world')).to eq 'hello world'
    end

    it 'should choose the correct and closest method to execute' do
      expect(A.new.concat('hello', 3) ).to eq 'hellohellohello'
    end

    it 'should choose the correct and closest method to execute' do
      expect(A.new.concat(['hello', ' world', '!'])).to eq 'hello world!'
    end

    it 'should choose the correct and closest method to execute' do
      expect(A.new.concat(Object.new, 3)).to eq 'Objetos concatenados'
    end


    it 'should throw error if no compatible definition is available' do
      expect{A.new.concat('hello', 'world', '!')}.to raise_error ArgumentError
    end

  end

  #describe 'Asking for the multimethods' do

  #  expect(A.multimethods).to eq [:concat]
  #  expect(A.multimethod(:concat)).to eq ??
  #end

end