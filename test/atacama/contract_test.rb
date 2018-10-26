# frozen_string_literal: true

require 'test_helper'

class ContractTestClass < Atacama::Contract
  option :params, type: Types::Strict::Hash

  def call
    :success
  end
end

describe Atacama::Contract do
  let(:valid_attributes) do
    { params: {} }
  end

  it 'executes the call block given all conditions are met' do
    assert_equal :success, ContractTestClass.call(**valid_attributes)
  end

  it 'makes the options available as local methods' do
    instance = ContractTestClass.new(context: valid_attributes)
    assert_equal instance.params, {}
  end

  it 'throws if a parameter is missing' do
    assert_raises(Atacama::ArgumentError) { ContractTestClass.call }
  end

  it 'throws if a parameter is of an invalid type' do
    assert_raises(Atacama::TypeError) do
      ContractTestClass.call(params: [])
    end
  end

  it 'throws if an unknown argument is passed' do
    assert_raises(Atacama::ArgumentError) do
      ContractTestClass.call(params: {}, invalid: true)
    end
  end
end
