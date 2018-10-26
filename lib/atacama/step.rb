# frozen_string_literal: true

require 'atacama/contract'
require 'atacama/values'

module Atacama
  class Step < Contract
    private

    # This value tells the orchestrator to merge in these parameters on the next call.
    # @param [Hash] the hash object to merge
    def Option(value)
      Values::Option.call(value: value)
    end

    def Return(value)
      Values::Return.call(value: value)
    end
  end
end
