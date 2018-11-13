# frozen_string_literal: true

require 'atacama/contract'
require 'atacama/values'
require 'atacama/transaction/halt_execution'
require 'atacama/transaction/definition'

module Atacama
  class Transaction < Contract
    include Values::Methods

    # The return value of all Transactions.
    class Result < Contract
      option :value, type: Types::Any
      option :transaction, type: Types.Instance(Context)
    end

    class << self
      attr_reader :return_option

      def inherited(subclass)
        super(subclass)
        subclass.returns_option return_option, return_type
        steps.each do |step|
          subclass.step(step.name, with: step.with, yielding: step.yielding)
        end
      end

      # Return the value of a given Option in the pipeline.
      #
      # @param key [Symbol] the option to read
      # @param type [Dry::Type?] the type object to optionally check
      def returns_option(key, type = nil)
        @return_option = key

        returns(
          Types.Instance(Result).constructor do |options|
            Atacama.check(type, options.value) do |e|
              raise ResultTypeMismatchError, "Invalid Result value for #{self}: #{e.message}"
            end

            options
          end
        )
      end

      # Add a step to the processing queue.
      #
      # @example
      #   step :extract, with: UserParamsExtractor
      #
      # @example a yielding step
      #   step :wrap, with: Wrapper do
      #     step :extract, with: UserParamsExtractor
      #   end
      #
      # @param name [Symbol] a unique name for a step
      # @param with [Contract, Proc, nil] the callable to execute
      #
      # @yield The captured block allows defining of child steps. The wrapper must implement yield.
      def step(name, with: nil, yielding: nil, &block)
        add_step({
          name: name,
          with: with,
          yielding: yielding || block_given? ? Class.new(self, &block) : nil
        })
      end

      # @private
      def add_step(params)
        steps.push(Definition.call(params))
      end

      # @private
      def steps
        @steps ||= []
      end
    end

    def initialize(context: {}, steps: {})
      super(context: context)
      @overrides = steps
      @return_value = nil
    end

    # Trigger execution of the Transaction pipeline.
    #
    # @return [Atacama::Transaction::Result] final result with value
    def call
      execute(self.class.steps)
      Result.call(value: return_value, transaction: context)
    end

    private

    def execute(steps)
      steps.each do |step|
        break if @return_value
        evaluate(step).tap do |result|
          @return_value = result.value if result.is_a? Values::Return
          context.merge!(result.value) if result.is_a? Values::Option
        end
      end
    end

    def evaluate(step)
      if overridden?(step)
        evaluate_override(step)
      elsif step.method_invocation?
        evaluate_method(step)
      elsif step.proc_invocation?
        evaluate_proc(step)
      else
        evaluate_instance(step)
      end
    end

    def overridden?(step)
      @overrides.key?(step.name)
    end

    def evaluate_override(step)
      callable = @overrides[step.name]
      instance_exec(&callable)
    end

    def evaluate_method(step)
      send(step.name) do
        execute(step.yielding.steps)
      end
    end

    def evaluate_proc(step)
      callable = step.with
      instance_exec(&callable)
    end

    def evaluate_instance(step)
      step.with.new(context: context) \
          .call { execute(step.yielding.steps) }
          .tap { |result| step.with.validate_return(result) }
    end

    def return_value
      @return_value || return_value_from_option || nil
    end

    def return_value_from_option
      self.class.return_option && context[self.class.return_option]
    end
  end
end
