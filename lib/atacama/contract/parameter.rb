# frozen_string_literal: true

module Atacama
  # A description of the signature of the parameter being validated
  class Parameter
    attr_reader :name, :type

    def initialize(name:, type: nil)
      @name = name
      @type = type
    end

    # Determine the validity of a value for an optionally given type. Raises a
    # type error on failure.
    #
    # @raise [Dry::Types::ConstraintError]
    def validate!(value)
      type[value] && nil unless type.nil?
    end
  end
end
