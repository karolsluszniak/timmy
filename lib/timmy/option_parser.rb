module Timmy
  class OptionParser
    class << self
      def parse
        if command_start_at = ARGV.find_index { |arg| arg == '--' }
          command = ARGV.slice!(command_start_at, ARGV.length - command_start_at)[1..-1]
        elsif ARGV[0] && !ARGV[0].start_with?('-')
          command = ARGV.slice!(0, ARGV.length)
        else
          command = nil
        end

        opts = {}

        ::OptionParser.new do |parser|
          parser.banner = <<-EOS
\e[1mtimmy\e[0m -- time execution of commands and their stages based on console output

\e[33mUsage:\e[0m

Pipe output from command:

    \e[36mCOMMAND | timmy [OPTIONS]\e[0m

Pass command as argument (records STDERR, gives more precise results):

    \e[36mtimmy [OPTIONS --] COMMAND\e[0m

Replay previous session:

    \e[36mcat LOGFILE | timmy [OPTIONS]\e[0m
EOS

          parser.separator ""
          parser.separator "\e[33mOptions:\e[0m"
          parser.separator ""

          parser.on("-q", "--quiet",
            "Don't print times and targeted timers (default: false)")
          parser.on("-p", "--precision NUM", Integer,
            "Set precision used when printing time (default: 0)")
          parser.on("-r", "--[no-]profile",
            "Profile slowest targeted timers (default: false)")
          parser.on("-x", "--replay-speed NUM", Float,
            "Replay with given speed (default: instant)")

          parser.separator ""
        end.parse!(into: opts)

        opts = opts.map { |key, value| [key.to_s.gsub('-', '_').to_sym, value] }.to_h
        opts[:command] = command if command

        opts
      end
    end
  end
end
