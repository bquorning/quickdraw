# frozen_string_literal: true

module Quickdraw
	autoload :Cluster, "quickdraw/cluster"
	autoload :Configuration, "quickdraw/configuration"
	autoload :Context, "quickdraw/context"
	autoload :Expectation, "quickdraw/expectation"
	autoload :Matchers, "quickdraw/matchers"
	autoload :Pipe, "quickdraw/pipe"
	autoload :Registry, "quickdraw/registry"
	autoload :Run, "quickdraw/run"
	autoload :Runner, "quickdraw/runner"
	autoload :Timer, "quickdraw/timer"
	autoload :Worker, "quickdraw/worker"
	autoload :Queue, "quickdraw/queue"
	autoload :Map, "quickdraw/map"

	autoload :ArgumentError, "quickdraw/argument_error"

	SUCCESS_EMOJI = %w[💃 🕺 🎉 🎊 💪 👏 🙌 ✨ 🥳 🎈 🌈 🎯 🏆]

	Null = Object.new.freeze
	Error = Module.new
	Config = Configuration.new

	def self.configure(&block)
		yield Config
		Config.freeze
	end
end
