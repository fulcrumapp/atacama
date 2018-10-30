# frozen_string_literal: true

require 'atacama/contract'
require 'atacama/transaction/halt_execution'
require 'atacama/transaction/definition'

module Atacama
  class Transaction < Contract
    include Values::Methods

    class Result < Contract
      option :success, type: Types::Boolean
      option :value, type: Types::Any
      option :transaction, type: Types::Any
    end

    class << self
      # @returns [Array<Atacama::Transaction::Definition>]
      def steps
        @steps ||= []
      end

      # Add a step to the processing queue.
      # @param name [Symbol] a unique name for a step
      def step(name, **kwargs, &block)
        kwargs[:yielding] = block_given? ? Class.new(self, &block) : nil
        kwargs[:with] ||= nil
        steps.push Definition.call(name: name, **kwargs)
      end
    end

    def initialize(context: {}, steps: {})
      super(context: context)
      @overrides = steps
    end

    def call
      value = begin
        execute(self.class.steps)
      rescue HaltExecution => exception
        exception.value
      end

      raise MissingReturn, "Return value from #{self.class} missing" unless value.is_a? Values::Return

      Result.call({
        value: value.value,
        transaction: context
      })
    end

    private

    def execute(steps)
      steps.each do |step|
        evaluate(step).tap do |result|
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
      instance_eval(&step.with)
    end

    def evaluate_instance(step)
      step.with.new(context: context).call do
        execute(step.yielding.steps)
      end
    end
  end
end
