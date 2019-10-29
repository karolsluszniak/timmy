module Timmy
  class Runner
    class << self
      def consume_stdin
        MasterTimer.start

        STDIN.each_line do |line|
          run_line(line.rstrip)
        end

        TargetedTimer.stop_all
        Logger.finalize
      end

      def replay_log(log)
        basename = File.basename(log)
        match = log.match(/timmy-(?<time>\d+)\+\d+.log/)
        time = match[:time].to_i

        MasterTimer.start(time)

        lines = File.readlines(log)
        lines.each do |line|
          if match = line.match(/^(?<m>\d+):(?<s>\d+(\.\d+)?) \| (?<content>.*)/)
            content = match[:content]
            time = match[:m].to_i * 60 + match[:s].to_f

            MasterTimer.set(time)
            run_line(content)
          end
        end

        TargetedTimer.stop_all
        Logger.finalize
      end

      private

      def run_line(line)
        TargetedTimer.start_for_line(line)
        Logger.put(line)
        TargetedTimer.stop_for_line(line)
      end
    end
  end
end
