require 'dry-types'
require 'atacama/version'
require 'atacama/contract'
require 'atacama/transaction'
require 'atacama/step'

module Atacama
  OptionTypeMismatchError = Class.new(StandardError)
  ReturnTypeMismatchError = Class.new(StandardError)
  ResultTypeMismatchError = Class.new(StandardError)

  # Execute a type check, catch and yield if theres an error.
  #
  # @yields [Exception] the caught type error
  #
  # @param type [Dry::Types?] type to check
  # @param value [Object] object to execute with
  def self.check(type, value)
    type && type[value]
    nil
  rescue Dry::Types::ConstraintError => exception
    yield exception
  end
end
