require 'dry-types'
require 'atacama/version'
require 'atacama/contract'
require 'atacama/transaction'
require 'atacama/step'

module Atacama
  ArgumentError = Class.new(StandardError)
  TypeError = Class.new(StandardError)
  MissingReturn = Class.new(StandardError)
  ReturnTypeMismatchError = Class.new(StandardError)
end
