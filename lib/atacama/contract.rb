# frozen_string_literal: true

require 'dry-types'

require 'atacama/contract/parameter'
require 'atacama/contract/validator'
require 'atacama/contract/context'

module Atacama
  # This class enables a DSL for creating a contract for the initializer
  class Contract
    # The type namespace to interact with DRY::Types
    module Types
      include Dry::Types.module
    end

    class << self
      def options
        @options ||= {}
      end

      def option(name, **kwargs)
        options[name] = Parameter.new(name: name, **kwargs)

        define_method name do
          context[name]
        end
      end

      def call(**kwargs)
        Validator.call(options: options, kwargs: kwargs)
        new(context: kwargs).call
      end
    end

    attr_reader :context

    def initialize(context: {})
      @context = Context.new(context)
    end

    def call
      self
    end
  end
end
