# frozen_string_literal: true

module Atacama
  class Validator
    def self.call(**kwargs)
      new.call(**kwargs)
    end

    # @param options [Hash] options schema
    # @param kwargs [Hash] keyword arguments to validate
    def call(options:, kwargs:)
      options.each do |(key, _)|
        raise ArgumentError unless kwargs.key?(key)
      end
    end
  end
end
