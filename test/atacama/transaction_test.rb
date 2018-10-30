# frozen_string_literal: true

require 'test_helper'
require 'atacama/transaction'

class TransactionStepTestClass < Atacama::Step
  def call
    Option(inner_value: 'executed')
  end
end

class TransactionYieldingStepTestClass < Atacama::Step
  def call
    start = Time.now
    yield
    Option(duration: Time.now - start)
  end
end

class TransactionTestClass < Atacama::Transaction
  ProcStep = proc do
    Option(lambda_value: 'lambda')
  end

  step :around, with: TransactionYieldingStepTestClass do
    step :inner, with: TransactionStepTestClass
    step :on_self
  end

  step :proc, with: ProcStep

  step :finally

  def on_self
    Option(returned_on_self: true)
  end

  def finally
    Return(self)
  end
end

describe Atacama::Transaction do
  describe 'step' do
    it 'allows defining a step in the transformation' do
      assert_operator 0, :<, TransactionTestClass.steps.count
    end

    it 'supports nesting steps do' do
      step = TransactionTestClass.steps.first
      assert_includes step.yielding.ancestors, Atacama::Transaction
      assert_includes step.yielding.steps.first.with.ancestors, Atacama::Step
    end
  end

  describe 'execution' do
    it 'takes option values and injects them in to the context' do
      result = TransactionTestClass.call
      assert_operator result.transaction.duration, :>, 0
      assert_equal 'executed', result.transaction.inner_value
      assert result.transaction.returned_on_self
    end

    it 'allows injecting of steps' do
      called = false

      TransactionTestClass.new(steps: {
        inner: lambda { called = true }
      }).call

      assert called, 'the mock object should have been called'
    end

    it 'allows early returns with the Return operator' do
      result = TransactionTestClass.new(steps: {
        inner: lambda { Return(:test) }
      }).call

      assert_equal :test, result.value
    end
  end
end
