module Timmy
  class ConfigLoader
    class << self
      def load
        home = Dir.home()
        config = File.join(home, ".timmy.rb")

        if File.exists?(config)
          eval(File.read(config))
        end
      end
    end

    def add_timer(id, start_regex:, stop_regex: nil)
      TargetedTimerDefinition.add(id, start_regex: start_regex, stop_regex: stop_regex)
    end

    def delete_timer(id)
      TargetedTimerDefinition.delete(id)
    end

    def set_precision(precision)
      Logger.set_precision(precision)
    end

    def set_logger_output_dir(dir)
      Logger.set_output_dir(dir)
    end

    def set_profile(profile)
      Logger.set_profile(profile)
    end

    def set_replay_speed(speed)
      Runner.set_replay_speed(speed)
    end
  end
end
