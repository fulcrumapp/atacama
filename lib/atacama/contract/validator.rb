# frozen_string_literal: true

module Atacama
  # Validation execution class for a given set of parameters and options.
  class Validator
    def self.call(**kwargs)
      new(**kwargs).call
    end

    # @param options [Hash] options schema
    # @param kwargs [Hash] keyword arguments to validate
    def initialize(options:, kwargs:)
      @options = options
      @kwargs = kwargs
    end

    def call
      detect_invalid_keywords!
      detect_invalid_types!
    end

    private

    attr_reader :options, :kwargs

    def detect_invalid_keywords!
      raise ArgumentError, "#{invalid_keys} are not valid options #{options.keys}" if invalid_keys.any?
    end

    def detect_invalid_types!
      options.each do |(key, parameter)|
        raise ArgumentError unless kwargs.key?(key)
        parameter.valid? kwargs[key]
      end
    end

    def invalid_keys
      kwargs.keys - options.keys
    end
  end
end
