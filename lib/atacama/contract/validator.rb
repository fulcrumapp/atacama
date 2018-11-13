# frozen_string_literal: true

module Atacama
  # Validation execution class for a given set of parameters and options.
  class Validator
    def self.call(**context)
      new(**context).call
    end

    # @param options [Hash] options schema
    # @param context [Atacama::Context] keyword arguments to validate
    def initialize(options:, context:, klass:)
      @options = options
      @context = context
      @klass = klass
    end

    def call
      detect_invalid_types!
    end

    private

    attr_reader :options, :context, :klass

    def detect_invalid_types!
      options.each do |key, parameter|
        value = context[key]
        Atacama.check parameter.type, value do |e|
          raise OptionTypeMismatchError, Atacama.format_exception(klass, e,
            "The value #{value.inspect} for #{key.inspect} is the incorrect type"
          )
        end
      end
    end
  end
end
