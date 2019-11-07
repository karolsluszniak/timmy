require "timmy/command_streamer"
require "timmy/config_loader"
require "timmy/logger"
require "timmy/master_timer"
require "timmy/option_parser"
require "timmy/runner"
require "timmy/targeted_timer"
require "timmy/targeted_timer_definition"
require "timmy/targeted_timer_manager"
require "timmy/version"

module Timmy
  module_function

  def configure
    yield(ConfigLoader.new)
  end
end
