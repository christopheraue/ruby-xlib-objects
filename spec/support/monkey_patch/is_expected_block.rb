module RSpec
  module Core
    module MemoizedHelpers
      def is_expected
        expect{ subject }
      end
    end
  end
  module Expectations
    class BlockExpectationTarget
      def to(matcher, message=nil, &block)
        @target = @target.call unless supports_block_expectations?(matcher)
        super
      end

      def not_to(matcher, message=nil, &block)
        @target = @target.call unless supports_block_expectations?(matcher)
        super
      end
    end
  end
end