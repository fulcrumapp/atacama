# frozen_string_literal: true

require 'atacama/types'
require 'atacama/contract/parameter'
require 'atacama/contract/validator'
require 'atacama/contract/context'

module Atacama
  # This class enables a DSL for creating a contract for the initializer
  class Contract
    RESERVED_KEYS = %i[call initialize context].freeze

    Types = Atacama::Types

    NameInterface = Types::Strict::Symbol.constrained(excluded_from: RESERVED_KEYS)
    ContextInterface = Types::Strict::Hash | Types.Instance(Context)

    class << self
      def injected=(hash)
        @injected = Types::Strict::Hash[hash]
      end

      def injected
        # Silences the VM warning about accessing uninitalized ivar
        defined?(@injected) ? @injected : {}
      end

      def options
        @options ||= {}
      end

      def returns(type)
        @returns = type
      end

      def return_type
        defined?(@returns) && @returns
      end

      def validate_return(value)
        return_type && return_type[value]
      end

      # Define an initializer value.
      # @param [Symbol] name of the argument
      def option(name, **kwargs)
        options[NameInterface[name]] = Parameter.new(name: name, **kwargs)

        define_method(name) { @context[name] }
        define_method("#{name}?") { !!@context[name] }
      end

      def call(context = {})
        new(context: context).call.tap do |result|
          validate_return(result)
        end
      end

      def inject(injected)
        clone.tap do |clone|
          clone.injected = injected
        end
      end
    end

    attr_reader :context

    def initialize(context: {}, **)
      ContextInterface[context] # Validate the type

      @context = Context.new(self.class.injected).tap do |ctx|
        ctx.merge!(context.is_a?(Context) ? context.to_h : context)
      end

      Validator.call(options: self.class.options, context: @context)
    end

    # Pretty pretty printing.
    def inspect
      "#<#{self.class}:0x%x %s>" % [
        object_id,
        self.class.options.keys.map do |option|
          "#{option}: #{context.send(option).inspect}"
        end.join(' ')
      ]
    end

    def call
      self
    end
  end
end
