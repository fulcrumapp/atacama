# frozen_string_literal: true

require 'atacama/contract'

module Atacama
  module Values
    # Helper methods for emitting value objects inside of a Contract.
    module Methods
      # rubocop:disable Naming/MethodName

      # This value tells the orchestrator to merge in these parameters on the
      # next call.
      # @param [Hash] the hash object to merge
      def Option(value)
        Values::Option.call(value: value)
      end

      def Return(value)
        raise HaltExecution.new(Values::Return.call(value: value))
      end
      # rubocop:enable Naming/MethodName
    end

    # This object notifies the Transaction that a new variable needs to be
    # merged in to the current context.
    class Option < Contract
      option :value, type: Types::Strict::Hash
    end

    # This object notifies the Transaction that a new
    class Return < Contract
      option :value
    end
  end
end
