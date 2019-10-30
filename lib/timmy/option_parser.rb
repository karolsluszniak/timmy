module Timmy
  class OptionParser
    class << self
      def parse
        opts = {}

        ::OptionParser.new do |parser|
          parser.banner = <<-EOS
\e[1mtimmy\e[0m -- time execution of commands and their stages based on console output

\e[33mUsage:\e[0m

Pipe output from arbitrary command:

    \e[36m[COMMAND] | timmy [OPTIONS]\e[0m

Replay previous session:

    \e[36mcat [LOGFILE] | timmy [OPTIONS]\e[0m
EOS

          parser.separator ""
          parser.separator "\e[33mOptions:\e[0m"
          parser.separator ""

          parser.on("-p", "--precision NUM", Integer,
            "Set precision used when printing time (default: 0)")
          parser.on("-r", "--[no-]profile",
            "Profile slowest targeted timers (default: false)")
          parser.on("-x", "--replay-speed NUM", Float,
            "Replay with given speed (default: instant)")

          parser.separator ""
        end.parse!(into: opts)

        opts.map { |key, value| [key.to_s.gsub('-', '_').to_sym, value] }.to_h
      end
    end
  end
end
