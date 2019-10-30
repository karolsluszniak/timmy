module Timmy
  class OptionParser
    class << self
      def parse
        options = {
          replay: nil,
          profile: false,
          logger_output_directory: nil,
          logger_precision: nil
        }

        ::OptionParser.new do |parser|
          parser.banner = <<-EOS
\e[1mtimmy\e[0m -- time execution of commands and their stages based on console output

\e[33mUsage:\e[0m

Pipe output from arbitrary command:

    \e[36m[COMMAND] | timmy [OPTIONS]\e[0m

Run without a pipe (usually with --replay):

    \e[36mtimmy [OPTIONS]\e[0m
EOS

          parser.separator ""
          parser.separator "\e[33mOptions:\e[0m"
          parser.separator ""

          parser.on("-r LOG", "--replay LOG", "Replay specific log file") do |replay|
            options[:replay] = replay
          end

          parser.on("-p", "--profile", "Profile targeted timers") do |profile|
            options[:profile] = profile
          end

          parser.on("--logger-output-dir DIR", "Save logs to different directory (default: \"/tmp\")") do |logger_output_directory|
            options[:logger_output_directory] = logger_output_directory
          end

          parser.on("--logger-precision NUM", Integer, "Set precision used when printing time (default: 0)") do |logger_precision|
            options[:logger_precision] = logger_precision
          end

          parser.separator ""
        end.parse!

        options
      end
    end
  end
end
