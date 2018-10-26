# frozen_string_literal: true

module Atacama
  # A description of the signature of the parameter being validated by the contract
  class Parameter
    attr_reader :name, :type

    def initialize(name:, type: nil)
      @name = name
      @type = type
    end

    def valid?(value)
      return true if type.nil?
      type[value]
    rescue Dry::Types::ConstraintError => error
      raise TypeError, error.message
    end
  end
end
