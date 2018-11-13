# frozen_string_literal: true

require 'atacama/types'
require 'atacama/contract/parameter'
require 'atacama/contract/validator'
require 'atacama/contract/context'

module Atacama
  # This class enables a DSL for creating a contract for the initializer
  class Contract
    # @private
    RESERVED_KEYS = %i[call initialize context].freeze

    # Namespace alias for easier reading when defining types.
    Types = Atacama::Types

    # @private
    NameInterface = Types::Strict::Symbol.constrained(excluded_from: RESERVED_KEYS)

    # @private
    ContextInterface = Types::Strict::Hash | Types.Instance(Context)

    class << self
      # Define an initializer value.
      #
      # @example Set an option
      #   option :model. type: Types.Instance(User)
      #
      # @param name [Symbol] name of the argument
      # @param type [Dry::Type?] the type object to optionally check
      def option(name, type: nil)
        options[NameInterface[name]] = Parameter.new(name: name, type: type)

        define_method(name) { @context[name] }
        define_method("#{name}?") { !!@context[name] }
      end

      # Set the return type for the contract. This is only validated automatically
      # through the #call class method.
      #
      # @param type [Dry::Type?] the type object to optionally check
      def returns(type) # rubocop:disable Style/TrivialAccessors
        @returns = type
      end

      # The main interface to executing contracts. Given a set of options it
      # will check the parameter types as well as return types, if defined.
      #
      # @param arguments [Hash] keyword arguments that match the defined options
      #
      # @yield the block is evaluated in the context of the instance call method
      #
      # @return The value of the #call instance method.
      def call(context = {}, &block)
        new(context: context).call(&block).tap { |result| validate_return(result) }
      end

      # Inject dependencies statically in to the Contract object. Allows for easier
      # composition of contracts when used in a Transaction.
      #
      # @example
      #   SampleClass.inject(user: User.new).call(attributes: { name: "Cindy" })
      #
      # @param injected [Hash] the options to inject in to the initializer
      #
      # @return [Class] a new class object that contains the injection
      def inject(injected)
        Validator.call({
          options: Hash[injected.keys.zip(options.values_at(*injected.keys))],
          context: Context.new(injected),
          klass: self
        })

        Class.new(self) do
          self.injected = injected
        end
      end

      # The defined return type on the Contract.
      #
      # @return [Dry::Type?] the type object to optionally check
      def return_type
        defined?(@returns) && @returns
      end

      # Execute type checking on a value for the defined return value. Useful
      # when executing `new` on these objects.
      #
      # @raise [Dry::Types::ConstraintError] a type check failure
      #
      # @param value [Any] the object to type check
      def validate_return(value)
        Atacama.check(return_type, value) do |e|
          raise ReturnTypeMismatchError, "#{self} return value invalid: #{e.message}"
        end
      end

      # The defined options on the contract.
      #
      # @return [Hash<String, Atacama::Parameter>]
      def options
        @options ||= {}
      end

      # Executed by the Ruby VM at subclass time. Ensure that all internal state
      # is copied to the new subclass.
      def inherited(subclass)
        subclass.returns(return_type)

        options.each do |name, parameter|
          subclass.option(name, type: parameter.type)
        end
      end

      # @private
      def injected=(hash)
        @injected = Types::Strict::Hash[hash]
      end

      # @private
      def injected
        # Silences the VM warning about accessing uninitalized ivar
        defined?(@injected) ? @injected : {}
      end
    end

    attr_reader :context

    # @raise [Dry::Types::ConstraintError] a type check failure
    #
    # @param context [Hash] the values to satisfy the option definition
    def initialize(context: {}, **)
      ContextInterface[context] # Validate the type

      @context = Context.new(self.class.injected).tap do |ctx|
        ctx.merge!(context.is_a?(Context) ? context.to_h : context)
      end

      Validator.call(options: self.class.options, context: @context, klass: self.class)
    end

    # @private
    def inspect
      "#<#{self.class}:0x%x %s>" % [
        object_id,
        self.class.options.keys.map do |option|
          "#{option}: #{context.send(option).inspect[0..20]}"
        end.join(' ')
      ]
    end

    # @abstract
    # The default entrypoint for all Contracts. This is executed and
    # type checked when called from the Class#call.
    def call
      self
    end
  end
end
