# frozen_string_literal: true

module Atacama
  class HaltExecution < StandardError
    attr_reader :value

    def initialize(value)
      super('Execution was halted and yielding a value with #value')
      @value = value
    end
  end
end
