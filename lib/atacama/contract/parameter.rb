# frozen_string_literal: true

module Atacama
  # A description of the signature of the parameter being validated
  class Parameter
    attr_reader :name, :type

    def initialize(name:, type: nil)
      @name = name
      @type = type
    end
  end
end
