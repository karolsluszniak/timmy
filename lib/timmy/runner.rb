module Timmy
  class Runner
    class << self
      def set_replay_speed(speed)
        @replay_speed = speed
      end

      def run
        ConfigLoader.load

        options = OptionParser.parse
        replay_speed = options[:replay_speed] || @replay_speed
        Logger.set_precision(options[:precision]) if options.key?(:precision)
        Logger.set_profile(options[:profile]) if options.key?(:profile)

        self.new(replay_speed: replay_speed).consume_stdin
      end
    end

    def initialize(replay_speed:)
      @replay_speed = replay_speed
      @last_replay_time = 0
    end

    def consume_stdin
      around_run_lines do
        STDIN.each_line do |line|
          next if init_replay_mode(line)

          if @replay_mode
            replay_line(line)
          else
            run_line(line.rstrip)
          end
        end

        Logger.put_eof unless @replay_mode
      end
    end

    private

    def init_replay_mode(line)
      if @replay_mode == nil
        if (match = line.match(/^TIMMY-SESSION:v1:(?<s>\d+\.\d{9})$/))
          MasterTimer.start(match[:s].to_f)
          @replay_mode = true
        else
          @replay_mode = false
        end
      end
    end

    def around_run_lines
      MasterTimer.start

      yield

      TargetedTimerManager.stop_all
      Logger.finalize
    end

    def replay_line(line)
      line_match = line.match(/^(?<s>\d+(\.\d+)?) (?<content>.*)/)
      line_time = line_match[:s].to_f

      duration = line_time - @last_replay_time
      sleep duration / @replay_speed if @replay_speed
      @last_replay_time = line_time

      MasterTimer.set(line_time)

      run_line(line_match[:content])
    end

    def run_line(line)
      TargetedTimerManager.start_for_line(line)
      Logger.put_output(line)
      TargetedTimerManager.stop_for_line(line)
    end
  end
end
