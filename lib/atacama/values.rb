# frozen_string_literal: true

# rubocop:disable Naming/MethodName

require 'atacama/contract'

module Atacama
  module Values
    module Methods
      # This value tells the orchestrator to merge in these parameters on the
      # next call.
      # @param [Hash] the hash object to merge
      def Option(value)
        Values::Option.call(value: value)
      end

      def Return(value)
        raise HaltExecution.new(Values::Return.call(value: value))
      end
    end

    class Option < Contract
      option :value, type: Types::Strict::Hash
    end

    class Return < Contract
      option :value
    end
  end
end

# rubocop:enable Naming/MethodName
