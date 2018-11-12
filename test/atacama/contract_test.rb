# frozen_string_literal: true

require 'test_helper'

class ContractTestClass < Atacama::Contract
  option :params, type: Types::Strict::Hash
  returns Types::Strict::Symbol
  def call
    :success
  end
end

class FailingContractReturnTypeTestClass < Atacama::Contract
  returns Types::Strict::Symbol

  def call
    "Hello!"
  end
end

describe Atacama::Contract do
  describe 'custom types' do
    it 'raises an error for the structure does not match the option names' do
      type = Atacama::Types.Option(name: Atacama::Types::Strict::String)
      assert_raises Dry::Types::ConstraintError do
        value = Atacama::Values::Option.call(value: { name: 1 })
        type[value]
      end
    end

    it 'uses the value from a correct option value' do
      type = Atacama::Types.Option(name: Atacama::Types::Strict::String)
      value = Atacama::Values::Option.call(value: { name: 'Hello' })
      assert_equal value, type[value]
    end

    it 'raises an error if the Return value is not correct' do
      type = Atacama::Types.Return(Atacama::Types::Strict::String)
      assert_raises Dry::Types::ConstraintError do
        value = Atacama::Values::Return.call(value: 1)
        type[value]
      end
    end

    it 'uses the value from a correct option value' do
      type = Atacama::Types.Return(Atacama::Types::Strict::String)
      value = Atacama::Values::Return.call(value: "Hello")
      assert_equal value, type[value]
    end
  end

  it 'explicitly checks the return type' do
    assert_raises Dry::Types::ConstraintError do
      FailingContractReturnTypeTestClass.call
    end
  end

  let(:valid_attributes) do
    { params: {} }
  end

  it 'executes the call block given all conditions are met' do
    assert_equal :success, ContractTestClass.call(**valid_attributes)
  end

  it 'makes the options available as local methods' do
    instance = ContractTestClass.new(context: valid_attributes)
    assert_equal instance.params, valid_attributes[:params]
  end

  it 'allows passing an existing context' do
    context = Atacama::Context.new(params: {})
    instance = ContractTestClass.new(context: context)
    assert_equal context, instance.context
  end

  it 'throws if a parameter is missing' do
    assert_raises(Atacama::ArgumentError) { ContractTestClass.call }
  end

  it 'allows creating callables with default options' do
    seed = { foo: 'bar' }
    instance = ContractTestClass.inject(params: seed).new
    assert_equal seed, instance.params
  end

  it 'copies related attributes on injection' do
    seed = { foo: 'bar' }
    klass = ContractTestClass.inject(params: seed)
    assert_equal ContractTestClass.return_type, klass.return_type
  end

  it 'throws if a parameter is of an invalid type' do
    assert_raises(Atacama::TypeError) do
      ContractTestClass.call(params: [])
    end
  end
end
