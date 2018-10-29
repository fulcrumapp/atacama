# frozen_string_literal: true

module Atacama
  # Validation execution class for a given set of parameters and options.
  class Validator
    def self.call(**context)
      new(**context).call
    end

    # @param options [Hash] options schema
    # @param context [Atacama::Context] keyword arguments to validate
    def initialize(options:, context:)
      @options = options
      @context = context
    end

    def call
      detect_invalid_types!
    end

    private

    attr_reader :options, :context

    def detect_invalid_types!
      options.each do |(key, parameter)|
        raise ArgumentError, "option not found: #{key}" unless context.key?(key)
        parameter.valid? context[key]
      end
    end
  end
end
