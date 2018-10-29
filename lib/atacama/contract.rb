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

      ContextOrHash = Strict::Hash | Instance(Context)
    end

    class << self
      def options
        @options ||= {}
      end

      # Define an initializer value.
      # @param [Symbol] name of the argument
      def option(name, **kwargs)
        options[name] = Parameter.new(name: name, **kwargs)

        define_method name do
          context[name]
        end
      end

      def call(context = {})
        new(context: context).call
      end
    end

    attr_reader :context

    def initialize(context: {}, **)
      context = Types::ContextOrHash[context]
      @context = context.is_a?(Context) ? context : Context.new(context)
      Validator.call(options: self.class.options, context: @context)
    end

    def call
      self
    end
  end
end
