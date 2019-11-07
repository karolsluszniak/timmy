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
        Logger.set_quiet(options[:quiet]) if options.key?(:quiet)
        Logger.set_precision(options[:precision]) if options.key?(:precision)
        Logger.set_profile(options[:profile]) if options.key?(:profile)

        instance = self.new(replay_speed: replay_speed)

        if command = options[:command]
          instance.stream_command(command)
        else
          instance.consume_stdin()
        end
      end
    end

    def initialize(replay_speed:)
      @replay_speed = replay_speed
      @last_replay_time = 0
    end

    def stream_command(command)
      around_run_lines do
        CommandStreamer.stream(command) do |type, line|
          run_line(line.rstrip, type)
        end
      end
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
      end
    end

    private

    def init_replay_mode(line)
      if @replay_mode == nil
        if (match = Logger.match_replay_header(line))
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

      Logger.put_eof unless @replay_mode
      TargetedTimerManager.stop_all
      Logger.finalize
    end

    def replay_line(line)
      line_match = Logger.match_replay_line(line)
      line_content = line_match[:content]
      line_time = line_match[:s].to_f
      line_type = (line_match.send(:[], :t) rescue nil) == 'e' ? :stderr : :stdout

      duration = line_time - @last_replay_time
      sleep duration / @replay_speed if @replay_speed
      @last_replay_time = line_time

      MasterTimer.set(line_time)

      run_line(line_content, line_type)
    end

    def run_line(line, type = :stdout)
      TargetedTimerManager.start_for_line(line)
      Logger.put_output(line, type == :stderr)
      TargetedTimerManager.stop_for_line(line)
    end
  end
end
