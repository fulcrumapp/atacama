# frozen_string_literal: true

require 'test_helper'

describe Atacama::Types do
  it 'generates a type that validates handles nil values' do
    assert_raises Dry::Types::ConstraintError do
      type = Atacama::Types.Return(Atacama::Types::Strict::String)
      type[nil]
    end
  end

  it 'generates a type that validates handles nil values' do
    assert_raises Dry::Types::ConstraintError do
      type = Atacama::Types.Option(example: Atacama::Types::Strict::String)
      type[nil]
    end
  end
end
