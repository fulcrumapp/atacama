# frozen_string_literal: true

module Atacama
  # The type namespace to interact with DRY::Types
  module Types
    include Dry::Types.module
    Boolean = Types::True | Types::False

    # Defines a type which checks that the Option value contains a valid
    # data structure.
    #
    # @param map [Hash] schema definition of the option value
    #
    # @return [Dry::Type]
    def self.Option(**map)
      Instance(Values::Option).constructor do |value_object|
        if value_object.is_a? Values::Option
          map.each do |key, type|
            value = value_object.value[key]
            Atacama.check(type, value) do |e|
              raise OptionTypeMismatchError, Atacama.format_exception(self, e,
                "The Option() #{key.inspect} value #{value.inspect} is the incorrect type."
              )
            end
          end
        end

        value_object
      end
    end

    # Defines a type which checks that the Return value contains a valid
    # object
    #
    # @param type [Dry::Type]
    #
    # @return [Dry::Type]
    def self.Return(type)
      Instance(Values::Return).constructor do |value_object|
        if value_object.is_a?(Values::Return)
          Atacama.check(type, value_object.value) do |e|
            raise ReturnTypeMismatchError, Atacama.format_exception(self, e,
              "The Return() value #{value_object.value.inspect} does not match the declared type."
            )
          end
        end

        value_object
      end
    end
  end
end
