# frozen_string_literal: true

require_relative "matchers/is_a"
require_relative "matchers/falsy"
require_relative "matchers/truthy"
require_relative "matchers/to_raise"
require_relative "matchers/equality"
require_relative "matchers/to_receive"
require_relative "matchers/to_not_raise"

class GreenDots::Test
	DEFAULT_MATCHERS = [
		GreenDots::Matchers::IsA,
		GreenDots::Matchers::Falsy,
		GreenDots::Matchers::Truthy,
		GreenDots::Matchers::ToRaise,
		GreenDots::Matchers::Equality,
		GreenDots::Matchers::ToReceive,
		GreenDots::Matchers::ToNotRaise
	]

	extend GreenDots::Context

	class << self
		def run(run = GreenDots::Run.new)
			return unless @tests

			new(run).run(@tests)
		end

		def include_matcher(*args)
			args.each { |m| matchers << m }
		end

		def matchers
			@matchers ||= if superclass < GreenDots::Test
				superclass.matchers.dup
			else
				Concurrent::Set.new(DEFAULT_MATCHERS)
			end
		end
	end

	def initialize(run)
		@run = run
		@expectations = []
		@matchers = self.class.matchers
	end

	def run(tests)
		tests.shuffle.each do |test|
			@name = test[:name]
			@skip = test[:skip]

			instance_eval(&test[:block])

			resolve
		end
	ensure
		@name = nil
		@skip = nil
	end

	def expect(value = nil, &block)
		matchers = @matchers # we need this to be a local variable because it's used in the block below
		expectation_class = GreenDots::EXPECTATION_SHAPES[matchers] ||= Class.new(GreenDots::Expectation) do
			matchers.each { include _1 }
			freeze
		end

		location = caller_locations(1, 1).first

		expectation = expectation_class.new(self, value, &block)

		@expectations << expectation
		expectation
	end

	def resolve
		@expectations.each(&:resolve)
	ensure
		@expectations.clear
	end

	def assert(value = nil, &block)
		expect(value, &block).truthy?
	end

	def refute(value = nil, &block)
		expect(value, &block).falsy?
	end

	def success!
		if @skip
			@run.failure! %(The skipped test "#{@name}" started passing.)
		else
			@run.success!
		end
	end

	def failure!(message)
		if @skip
			@run.success!
		else
			@run.failure!(message)
		end
	end
end
