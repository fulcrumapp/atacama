# frozen_string_literal: true

require 'test_helper'
require 'atacama/step'

class StepReturningOptionFake < Atacama::Step
  returns Types.Option(foo: Types::Strict::String)
  def call
    Option(foo: 'bar')
  end
end

class StepReturningReturnFake < Atacama::Step
  def call
    Return(true)
  end
end

describe Atacama::Step do
  it 'can return a Option value object' do
    result = StepReturningOptionFake.call
    assert_instance_of Atacama::Values::Option, result
    assert_equal({ foo: 'bar' }, result.value)
  end

  it 'can return a Return value object' do
    assert_equal true, StepReturningReturnFake.call.value
  end
end
