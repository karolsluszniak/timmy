module Timmy
  class Runner
    class << self
      def run
        ConfigLoader.load

        options = OptionParser.parse

        if value = options[:logger_output_directory]
          Logger.set_output_directory(value)
        end

        if value = options[:logger_precision]
          Logger.set_precision(value)
        end

        if replay = options[:replay]
          replay_log(replay)
        else
          consume_stdin
        end

        if options[:profile]
          Logger.put_stopped_profiles
        end
      end

      def consume_stdin
        around_run_lines do
          STDIN.each_line do |line|
            run_line(line.rstrip)
          end
          Logger.put_output("EOF")
        end
      end

      def replay_log(log)
        around_run_lines do
          start_time = File.basename(log).match(/timmy-(?<time>\d+)\+\d+.log/)[:time].to_i
          MasterTimer.start(start_time)

          File.readlines(log).each do |line|
            if match = line.match(/^(?<m>\d+):(?<s>\d+(\.\d+)?) \| (?<content>.*)/)
              line_time = match[:m].to_i * 60 + match[:s].to_f
              MasterTimer.set(line_time)
              run_line(match[:content])
            elsif match = line.match(/^(?<s>\d+(\.\d+)?) (?<content>.*)/)
              line_time = match[:s].to_f
              MasterTimer.set(line_time)
              run_line(match[:content])
            end
          end
        end
      end

      private

      def around_run_lines
        MasterTimer.start

        yield

        TargetedTimerManager.stop_all
        Logger.finalize
      end

      def run_line(line)
        TargetedTimerManager.start_for_line(line)
        Logger.put_output(line)
        TargetedTimerManager.stop_for_line(line)
      end
    end
  end
end
