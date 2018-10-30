require 'atacama/version'
require 'atacama/contract'

module Atacama
  ArgumentError = Class.new(StandardError)
  TypeError = Class.new(StandardError)
  MissingReturn = Class.new(StandardError)
end
