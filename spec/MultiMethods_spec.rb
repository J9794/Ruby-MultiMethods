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
          expect(A.multimethods).to eq [:respond_to?,:concat]
        end
        it 'should return the array of partialblocks which represents the multimethod' do
          expect(A.multimethod(:concat).is_a? Array).to be true
        end
        it 'should be true that all of the elements on the array are partialblocks' do
          expect(A.multimethod(:concat).all? do |mm| mm.is_a? PartialBlock end).to be true
        end
      end

    describe 'respond_to?' do

      it 'should respond if the method is a known multimethod' do
        expect(A.new.respond_to?(:concat)).to be true
       end

      it 'should respond if the method is a known regular method' do
        expect(A.new.respond_to?(:to_s)).to be true
      end

      it 'should respond if the method is a known multimethod and the types are correct' do
        expect(A.new.respond_to?(:concat, false, [String,String])).to be true
      end

      it 'should respond if the method is a known multimethod and the types are correct' do
        expect(A.new.respond_to?(:concat, false, [Integer,A])).to be true
      end

      it 'should not respond if the method is a regular method and types are provided' do
        expect(A.new.respond_to?(:to_s, false, [String]) ).to be false
      end

      it 'should not respond if the method is a multimethod but the types are not correct' do
        expect(A.new.respond_to?(:concat, false, [String,String,String])).to be false
      end

      # true, define el método como multimethod
        # true, define el método normalmente
        # true, los tipos coinciden
        # true, matchea con [Object, Object]
        # false, no es un multimethod
         # false, los tipos no coinciden


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
        expect(my_object.singleton_class.multimethods).to eq [:respond_to?,:concat]
      end
      it 'should return the array of partialblocks which represents the multimethod' do
        expect(my_object.singleton_class.multimethod(:concat).is_a? Array).to be true
      end
      it 'should be true that all of the elements on the array are partialblocks' do
        expect(my_object.singleton_class.multimethod(:concat).all? do |mm| mm.is_a? PartialBlock end).to be true
      end
    end

  end


  describe 'MultiMethods of a subclass' do

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
    class B < A
      partial_def(:b_method,[]) do "I am B" end
    end

    describe 'Calling the methods' do


      it 'should choose the correct and closest method to execute' do
        expect(B.new.concat('hello', ' world')).to eq 'hello world'
      end

      it 'should choose the correct and closest method to execute' do
        expect(B.new.concat('hello', 3) ).to eq 'hellohellohello'
      end

      it 'should choose the correct and closest method to execute' do
        expect(B.new.concat(['hello', ' world', '!'])).to eq 'hello world!'
      end

      it 'should choose the correct and closest method to execute' do
        expect(B.new.concat(Object.new, 3)).to eq 'Objetos concatenados'
      end


      it 'should throw error if no compatible definition is available' do
        expect{B.new.concat('hello', 'world', '!')}.to raise_error ArgumentError
      end

    end

    describe 'Asking for the multimethods' do

      it 'should return one symbol representing the multimethod' do
        expect(B.multimethods).to eq [:respond_to?, :concat, :b_method]
      end
      it 'should return the array of partialblocks which represents the multimethod' do
        expect(B.multimethod(:concat).is_a? Array).to be true
      end
      it 'should return the array of partialblocks which represents the multimethod' do
        expect(B.multimethod(:b_method).is_a? Array).to be true
      end
      it 'should be true that all of the elements on the array are partialblocks' do
        expect(B.multimethod(:concat).all? do |mm| mm.is_a? PartialBlock end).to be true
      end
      it 'should be true that all of the elements on the array are partialblocks' do
        expect(B.multimethod(:b_method).all? do |mm| mm.is_a? PartialBlock end).to be true
      end

    end

  end

end