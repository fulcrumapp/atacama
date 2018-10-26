# frozen_string_literal: true

require 'atacama/contract'

module Atacama
  module Values
    class Option < Contract
      option :value, type: Types::Strict::Hash
    end

    class Return < Contract
      option :value
    end
  end
end
