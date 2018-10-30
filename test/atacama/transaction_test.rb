# frozen_string_literal: true

require 'test_helper'
require 'atacama/transaction'

class TestSplitter < Atacama::Step
  option :sentence, type: Types::Strict::String

  def call
    Option(words: sentence.split(' '))
  end
end

class TestBenchmarking < Atacama::Step
  def call
    start = Time.now
    yield
    Option(duration: Time.now - start)
  end
end

class TransactionTestClass < Atacama::Transaction
  option :sentence, type: Types::Strict::String

  Joiner = proc do
    Option(sentence: context.words.join(' '))
  end

  step :benchmark, with: TestBenchmarking do
    step :splitter, with: TestSplitter
    step :reverser
    step :joiner, with: Joiner
  end

  step :finally, with: -> { Return(context.sentence) }

  private

  def reverser
    Option(words: context.words.reverse)
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
    it 'executes the pipeline, passing through options until the final return value' do
      result = TransactionTestClass.call(sentence: 'Hello World!')
      assert_operator result.transaction.duration, :>, 0
      assert_equal 'World! Hello', result.value
    end

    it 'allows injecting of steps to faciliate mocking' do
      called = false

      result = TransactionTestClass.new(
        steps: { reverser: -> { called = true } },
        context: { sentence: 'Hello World!' }
      ).call

      assert called, 'the mock object should have been called'
      assert_equal 'Hello World!', result.transaction.sentence
    end

    it 'allows early returns with the Return operator' do
      result = TransactionTestClass.new(
        steps: { splitter: -> { Return(:test) } },
        context: { sentence: 'Hello World!' }
      ).call

      assert_equal :test, result.value
    end
  end
end
