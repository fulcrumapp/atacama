# frozen_string_literal: true

require 'atacama/contract'

module Atacama
  class Transaction < Contract
    # Struct object holding the step definition
    class Definition < Contract
      option :name, type: Types::Strict::Symbol
      option :with, type: Types::Any.optional
      option :yielding, type: Types::Any.optional

      def yielding?
        !!yielding
      end
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
        steps.push Definition.call(name: name, **kwargs)
      end
    end

    def initialize(context: {}, steps: {})
      super(context: context)
      @overrides = steps
    end

    def call
      execute(self.class.steps)
      self
    end

    private

    def execute(steps)
      steps.each do |step|
        result = evaluate(step)

        if result.is_a? Values::Option
          context.merge!(result.value)
        elsif result.is_a? Values::Return
          # Halt execution and return the inner value.
        end
      end
    end

    def evaluate(step)
      instance = override_for(step) || step.with.new(context: context)

      if step.yielding?
        instance.call { execute(step.yielding.steps) }
      else
        instance.call
      end
    end

    def override_for(step)
      override = @overrides[step.name]
      return if override.nil?
      override
    end
  end
end
