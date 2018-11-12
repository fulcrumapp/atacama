# frozen_string_literal: true

module Atacama
  # The type namespace to interact with DRY::Types
  module Types
    include Dry::Types.module
    Boolean = Types::True | Types::False

    def self.Option(**map)
      Instance(Values::Option).constructor do |options|
        if options.is_a? Values::Option
          map.each { |key, type| type[options.value[key]] }
        end

        options
      end
    end

    def self.Return(type)
      Instance(Values::Return).constructor do |options|
        type[options.value] if options.is_a? Values::Return
        options
      end
    end
  end
end
