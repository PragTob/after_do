require 'spec_helper'

describe AfterDo do
  let(:dummy_instance) {@dummy_class.new}
  let(:mockie) {double}

  before :each do
    redefine_dummy_class
  end

  def redefine_dummy_class
    @dummy_class = Class.new do
      extend AfterDo
      def zero
        0
      end

      def one(param)
        param
      end

      def two(param1, param2)
        param2
      end
    end
  end


  it 'responds to after' do
    @dummy_class.should respond_to :after
  end

  it 'calls a method on the injected mockie' do
    mockie.should_receive :call_method
    @dummy_class.after :zero do mockie.call_method end
    dummy_instance.zero
  end

  it 'does not change the return value' do
    before = dummy_instance.zero
    @dummy_class.after :zero do 42 end
    after = dummy_instance.zero
    after.should eq before
  end

  it 'marks the copied method as private' do
    @dummy_class.after :zero do end
    copied_method_name = (AfterDo::ALIAS_PREFIX + 'zero').to_sym
    dummy_instance.respond_to?(copied_method_name).should be_false
  end

  it 'can add multiple call backs' do
    mockie.should_receive :call_method
    mock2 = double
    mock2.should_receive :call_another_method
    mock3 = double
    mock3.should_receive :bla
    @dummy_class.after :zero do mockie.call_method end
    @dummy_class.after :zero do mock2.call_another_method end
    @dummy_class.after :zero do mock3.bla end
    dummy_instance.zero
  end

  it 'can remove all callbacks' do
    mockie.should_not_receive :call_method
    @dummy_class.after :zero do mockie.call_method end
    @dummy_class.remove_all_callbacks
    dummy_instance.zero
  end

  it 'throws an error when you try to add a hook to a non existing method' do
    expect do
      @dummy_class.after :non_existing_method do ; end
    end.to raise_error(NonExistingMethodError)
  end

  describe 'with parameters' do

    before :each do
      mockie.should_receive :call_method
    end

    it 'can handle methods with a parameter' do
      @dummy_class.after :one do mockie.call_method end
      dummy_instance.one 5
    end

    it 'can handle methods with 2 parameters' do
      @dummy_class.after :two do mockie.call_method end
      dummy_instance.two 5, 8
    end
  end

  describe 'with parameters for the given block' do
    it 'can handle one block parameter' do
      mockie.should_receive(:call_method).with(5)
      @dummy_class.after :one do |i| mockie.call_method i end
      dummy_instance.one 5
    end

    it 'can handle two block parameters' do
      mockie.should_receive(:call_method).with(5, 8)
      @dummy_class.after :two do |i, j| mockie.call_method i, j end
      dummy_instance.two 5, 8
    end
  end

  describe 'multiple methods' do
    def call_all_3_methods
      dummy_instance.zero
      dummy_instance.one 4
      dummy_instance.two 4, 5
    end

    it 'can take multiple method names as arguments' do
      mockie.should_receive(:call_method).exactly(3).times
      @dummy_class.after :zero, :one, :two do mockie.call_method end
      call_all_3_methods
    end

    it 'can get the methods as an Array' do
      mockie.should_receive(:call_method).exactly(3).times
      @dummy_class.after [:zero, :one, :two] do mockie.call_method end
      call_all_3_methods
    end

    it 'raises an error when no method is specified' do
      expect do
        @dummy_class.after do mockie.call_method end
      end.to raise_error ArgumentError
    end
  end

  describe 'it can get a hold of self, if needbe' do
    it 'works for a method without arguments' do
      mockie.should_receive(:call_method).with(dummy_instance)
      @dummy_class.after :zero do |object| mockie.call_method(object) end
      dummy_instance.zero
    end

    it 'works for a method with 2 arguments' do
      mockie.should_receive(:call_method).with(1, 2, dummy_instance)
      @dummy_class.after :two do |first, second, object|
        mockie.call_method(first, second, object)
      end
      dummy_instance.two 1, 2
    end
  end

  describe 'inheritance' do
    let(:inherited_instance) {@inherited_class.new}

    before :each do
      define_inherited_class
    end

    def define_inherited_class
      @inherited_class = Class.new @dummy_class
    end

    it 'class knows about the after method' do
      @inherited_class.should respond_to :after
    end

    describe 'callback on parent class' do
      before :each do
        @dummy_class.after :zero do mockie.call end
      end

      it 'works when we have a callback on the parent class' do
        mockie.should_receive :call
        inherited_instance.zero
      end

      it 'remove_callbacks does not remove the callbacks on parent class' do
        mockie.should_receive :call
        @inherited_class.remove_all_callbacks
        inherited_instance.zero
      end

      it 'remove_callbacks on the parent does remove the callbacks' do
        mockie.should_not_receive :call
        @dummy_class.remove_all_callbacks
        inherited_instance.zero
      end
    end
  end
end