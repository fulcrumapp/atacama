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
        Atacama.check parameter.type, context[key] do |e|
          raise OptionTypeMismatchError, %(#{klass} option :#{key} invalid: #{e.message})
        end
      end
    end
  end
end
