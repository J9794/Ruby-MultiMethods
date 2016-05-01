require 'rspec'
require_relative '../src/MultiMethods'

describe 'MultiMethods' do

  describe 'MultiMethods of a class' do

      class A
        include PartialDefinable
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

      describe 'Asking for the multimethods' do

        it 'should return one symbol representing the multimethod' do
          expect(A.multimethods).to eq [:concat]
        end
        it 'should return the array of partialblocks which represents the multimethod' do
          expect(A.multimethod(:concat).is_a? Array).to be true
        end
        it 'should be true that all of the elements on the array are partialblocks' do
          expect(A.multimethod(:concat).all? do |mm| mm.is_a? PartialBlock end).to be true
        end
      end

  end


  describe 'MultiMethods of a singleton class' do

    my_object = Object.new
    my_object.singleton_class.class_eval do
      include PartialDefinable
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
        expect(my_object.concat('hello', ' world')).to eq 'hello world'
      end

      it 'should choose the correct and closest method to execute' do
        expect(my_object.concat('hello', 3) ).to eq 'hellohellohello'
      end

      it 'should choose the correct and closest method to execute' do
        expect(my_object.concat(['hello', ' world', '!'])).to eq 'hello world!'
      end

      it 'should choose the correct and closest method to execute' do
        expect(my_object.concat(Object.new, 3)).to eq 'Objetos concatenados'
      end


      it 'should throw error if no compatible definition is available' do
        expect{my_object.concat('hello', 'world', '!')}.to raise_error ArgumentError
      end

    end

    describe 'Asking for the multimethods' do

      it 'should return one symbol representing the multimethod' do
        expect(my_object.singleton_class.multimethods).to eq [:concat]
      end
      it 'should return the array of partialblocks which represents the multimethod' do
        expect(my_object.singleton_class.multimethod(:concat).is_a? Array).to be true
      end
      it 'should be true that all of the elements on the array are partialblocks' do
        expect(my_object.singleton_class.multimethod(:concat).all? do |mm| mm.is_a? PartialBlock end).to be true
      end
    end

  end

end