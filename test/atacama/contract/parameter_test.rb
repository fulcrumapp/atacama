# frozen_string_literal: true

require 'test_helper'
require 'atacama/contract/parameter'

describe Atacama::Parameter do
  it 'has visible getters for the properties' do
    param = Atacama::Parameter.new(name: :test)
    assert_equal :test, param.name
  end

  it 'supports type checking without a defined type' do
    param = Atacama::Parameter.new(name: :test)
    assert_nil param.validate!(:test)
  end

  it 'raises an exception if the type specified is not present' do
    type = Atacama::Contract::Types::Strict::String
    param = Atacama::Parameter.new(name: :test, type: type)

    assert_raises(Dry::Types::ConstraintError) { param.validate!(true) }

    assert_nil param.validate!('Hello')
  end
end
