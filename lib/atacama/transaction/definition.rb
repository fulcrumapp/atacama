# frozen_string_literal: true

module Atacama
  # Struct object holding the step definition
  class Definition < Contract
    option :name, type: Types::Strict::Symbol
    option :with, type: Types::Any.optional
    option :yielding, type: Types::Any.optional

    def proc_invocation?
      with.is_a? Proc
    end

    def method_invocation?
      with.nil?
    end
  end
end
