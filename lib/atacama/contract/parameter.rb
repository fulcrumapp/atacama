# frozen_string_literal: true

module Atacama
  # A description of the signature of the parameter being validated by the contract
  class Parameter
    attr_reader :name, :type

    def initialize(name:, type: nil)
      @name = name
      @type = type
    end

    # Determine the validity of a value for an optionally given type. Raises a type
    # error on failure.
    # @raise [Atacama::TypeError]
    # @returns Boolean
    def valid?(value)
      return true if type.nil?
      type[value]
      true
    rescue Dry::Types::ConstraintError => error
      raise TypeError, error.message
    end
  end
end
