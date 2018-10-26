# frozen_string_literal: true

require 'test_helper'

class ContractTestClass < Atacama::Contract
  option :params, type: Types::Strict::Hash

  def call
    self
  end
end

describe Atacama::Contract do
  it 'adds an option definition to the schema' do
    refute_equal 0, ContractTestClass.options.length
  end

  it 'validates that that the parameter exists' do
    assert_raises(Atacama::ArgumentError) { ContractTestClass.call }
  end

  it 'makes the options available as local methods' do
    assert_equal Hash.new, ContractTestClass.call(params: {}).params
  end
end
