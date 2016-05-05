require 'rspec'
require_relative '../src/MultiMethods'

shared_context 'Multimethods Behavior' do |receiver_instance, receiver_class, multi_methods_list|

  describe 'Calling the methods' do

    describe 'Methods that does not use self' do

      it 'should choose the correct and closest method to execute' do
        expect(receiver_instance.concat('hello', ' world')).to eq 'hello world'
      end

      it 'should choose the correct and closest method to execute' do
        expect(receiver_instance.concat('hello', 3) ).to eq 'hellohellohello'
      end

      it 'should choose the correct and closest method to execute' do
        expect(receiver_instance.concat(['hello', ' world', '!'])).to eq 'hello world!'
      end

      it 'should choose the correct and closest method to execute' do
        expect(receiver_instance.concat(Object.new, 3)).to eq 'Objetos concatenados'
      end

      it 'should throw error if no compatible definition is available' do
        expect{receiver_instance.concat('hello', 'world', '!')}.to raise_error ArgumentError
      end

    end


    describe 'Methods that use self' do

      it 'should use its instance variable' do
        expect(receiver_instance.concat('Mr. Sarlomps')).to eq receiver_instance.instance_variable_get(:@text) + 'Mr. Sarlomps'
      end

    end

  end

  describe 'Asking for the multimethods' do

    it 'should return one symbol representing the multimethod' do
      expect(receiver_class.multimethods).to include *multi_methods_list
    end
    it 'should return the array of partialblocks which represents the multimethod' do
      expect(receiver_class.multimethod(:concat).is_a? Array).to be true
    end
    it 'should be true that all of the elements on the array are partialblocks' do
      expect(receiver_class.multimethod(:concat).all? do |mm| mm.is_a? PartialBlock end).to be true
    end
  end

  describe 'respond_to?' do

    it 'should respond if the method is a known multimethod' do
      expect(receiver_instance.respond_to?(:concat)).to be true
    end

    it 'should respond if the method is a known regular method' do
      expect(receiver_instance.respond_to?(:to_s)).to be true
    end

    it 'should respond if the method is a known multimethod and the types are correct' do
      expect(receiver_instance.respond_to?(:concat, false, [String,String])).to be true
    end

    it 'should respond if the method is a known multimethod and the types are correct' do
      expect(receiver_instance.respond_to?(:concat, false, [Integer,A])).to be true
    end

    it 'should not respond if the method is a regular method and types are provided' do
      expect(receiver_instance.respond_to?(:to_s, false, [String]) ).to be false
    end

    it 'should not respond if the method is a multimethod but the types are not correct' do
      expect(receiver_instance.respond_to?(:concat, false, [String,String,String])).to be false
    end

  end

end

describe 'MultiMethods' do

  describe 'MultiMethods of a class' do

      class A

        def initialize
          @text = "I'm an A, "
        end

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

        partial_def :concat, [String] do |name|
          @text + name
        end

      end

      include_context 'Multimethods Behavior',A.new,A,[:respond_to?,:concat]


  end


  describe 'MultiMethods of a singleton class' do

    my_object = Object.new
    my_object.instance_variable_set(:@text,'I am a singular object!, nice to meet you, ')
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

      partial_def :concat, [String] do |name|
        @text + name
      end
    end

    include_context 'Multimethods Behavior',my_object,my_object.singleton_class,[:respond_to?,:concat]


  end


  describe 'MultiMethods of a subclass' do

    class A
      def initialize
        @text = "I'm an A"
      end

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
      def initialize
        @text = "I'm a B!, "
      end
      partial_def(:b_method,[]) do "I am B" end
      partial_def(:b_method,[String]) do |nom| "I am #{nom}" end
      partial_def(:concat, [Array,String]) do |a,b| "#{a.join(', ')} y #{b}"end
      partial_def :concat, [String] do |name|  @text + name  end
    end

    include_context 'Multimethods Behavior',B.new,B,[:respond_to?,:concat,:b_method]

    describe 'Multimethods of a subclass specific behavior' do

      describe 'Calling the methods' do

      it 'should choose the correct and closest method to execute' do
        expect(B.new.concat(['horacio','la maga'], 'rocamadour')).to eq 'horacio, la maga y rocamadour'
      end

    end

      describe 'Asking for the multimethods' do

      it 'should return the array of partialblocks which represents the multimethod' do
        expect(B.multimethod(:b_method).is_a? Array).to be true
      end
      it 'should be true that all of the elements on the array are partialblocks' do
        expect(B.multimethod(:b_method).all? do |mm| mm.is_a? PartialBlock end).to be true
      end

    end

      describe 'respond_to?' do

      it 'should respond if the method is a known multimethod' do
        expect(B.new.respond_to?(:b_method)).to be true
      end

      it 'should respond if the method is a known multimethod and the types match' do
        expect(B.new.respond_to?(:b_method,false,[])).to be true
      end

      it 'should respond if the method is a known multimethod and the types match' do
        expect(B.new.respond_to?(:b_method,false,[String])).to be true
      end

    end

    end

  end

end