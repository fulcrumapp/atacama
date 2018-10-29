# frozen_string_literal: true

require 'ostruct'

module Atacama
  # Generic object store for passing values between contracts
  class Context < OpenStruct
    alias key? respond_to?

    def merge!(hash)
      hash.each do |(key, value)|
        self[key] = value
      end
    end
  end
end
