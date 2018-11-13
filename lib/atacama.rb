require 'dry-types'
require 'atacama/version'
require 'atacama/contract'
require 'atacama/transaction'
require 'atacama/step'

module Atacama
  OptionTypeMismatchError = Class.new(StandardError)
  ReturnTypeMismatchError = Class.new(StandardError)
  ResultTypeMismatchError = Class.new(StandardError)
end
