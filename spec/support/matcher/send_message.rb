RSpec::Matchers.define :send_message do |message|
  define_method :matcher do
    @matcher ||= ::RSpec::Mocks::Matchers::HaveReceived.new(message)
  end

  match do |actual|
    block_given = false
    correct_block_given = false
    block_checker = Proc.new do |&block|
      block_given = !!block
      correct_block_given = block == @block
    end

    allow(@receiver).to receive(message, &block_checker).and_return(@return_value)
    actual.call

    block_given = @block_expected ? block_given : true
    block_correct = @block ? correct_block_given : true
    block_as_expected = block_given && block_correct
    matcher.matches?(@receiver) && block_as_expected
  end

  ::RSpec::Mocks::Matchers::HaveReceived::CONSTRAINTS.each do |expectation|
    chain expectation do |*args|
      matcher.send(expectation, *args)
    end
  end

  chain :to do |receiver|
    @receiver = receiver
  end

  chain :with_block do |block = nil|
    @block_expected = true
    @block = block
  end

  chain :and_return do |value|
    @return_value = value
  end

  description do
    matcher.description.sub('have received', 'send message') <<
      " to #{@receiver}" <<
      (@block ? ' with block' : '')
  end

  supports_block_expectations
end