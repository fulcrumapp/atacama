# frozen_string_literal: true

require 'dry-types'

require 'atacama/contract/parameter'
require 'atacama/contract/validator'
require 'atacama/contract/context'

module Atacama
  # The type namespace to interact with DRY::Types
  module Types
    include Dry::Types.module
    Boolean = Types::True | Types::False
    ContextOrHash = Strict::Hash | Instance(Context)
  end

  # This class enables a DSL for creating a contract for the initializer
  class Contract
    RESERVED_KEYS = %i[call initialize context].freeze

    NameInterface = Types::Strict::Symbol.constrained(excluded_from: RESERVED_KEYS)

    class << self
      def options
        @options ||= {}
      end

      # Define an initializer value.
      # @param [Symbol] name of the argument
      def option(name, **kwargs)
        # Validate it's a symbol and not reserved
        name = NameInterface[name]

        options[name] = Parameter.new(name: name, **kwargs)

        define_method(name) { @context[name] }
        define_method("#{name}?") { !!@context[name] }
      end

      def call(context = {})
        new(context: context).call
      end
    end

    attr_reader :context

    def initialize(context: {}, **)
      # Validate the type
      Types::ContextOrHash[context]
      @context = context.is_a?(Context) ? context : Context.new(context)
      Validator.call(options: self.class.options, context: @context)
    end

    def call
      self
    end
  end
end
