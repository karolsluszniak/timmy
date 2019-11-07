module Timmy
  class Logger
    class << self
      def set_output_dir(dir)
        @output_dir = File.expand_path(dir)
      end

      def set_quiet(quiet)
        @quiet = quiet
      end

      def set_precision(precision)
        @precision = precision
      end

      def set_profile(profile)
        @profile = profile
      end

      def match_replay_header(line)
        line.match(/^TIMMY-SESSION:v1:(?<s>\d+\.\d{9})$/)
      end

      def match_replay_line(line)
        line.match(/^(?<s>\d+(\.\d+)?)(?<t>e)? (?<content>.*)/)
      end

      def put_output(output, error = false)
        duration = MasterTimer.get

        if @quiet
          puts output
        else
          formatted_duration = format_duration(duration)
          formatted_duration = red(formatted_duration) if error
          puts "\e[0m" + feint(formatted_duration) + " " + output
        end
        $stdout.flush

        @output ||= ''
        @output += sprintf("%.9f%s %s\n", duration, error ? 'e' : '', output)
      end

      def put_eof
        put_output(feint("EOF")) unless @quiet
      end

      def put_timer(timer)
        do_put_timer(timer) unless @quiet
      end

      def finalize
        save
        put_profile if profile?
      end

      private

      def save
        suffix = "#{MasterTimer.start.to_i}+#{MasterTimer.get.to_i}"
        filename = File.join(output_dir, "timmy-#{suffix}.log")

        return if File.exists?(filename)

        header = sprintf("TIMMY-SESSION:v1:%.9f\n", MasterTimer.start)
        File.write(filename, header + @output)
        puts feint("Log written to #{filename}")
        puts
      end

      def do_put_timer(timer)
        puts format_timer(timer)
        $stdout.flush
      end

      def put_profile
        slowest_timers = TargetedTimerManager
          .stopped
          .sort_by { |timer| -timer.duration }
          .slice(0, 10)

        return unless slowest_timers.any?

        puts "Slowest targeted timers:"

        slowest_timers.each do |timer|
          put_timer(timer)
        end

        puts
      end

      def format_timer(timer)
        string = (
          bold(format_duration(timer.duration)) +
          " " +
          bold(green(format_id(timer.definition.id)))
        )

        string += " " + green("(" + timer.group + ")") if timer.group
        string += " #{timer.label}" if timer.label

        string
      end

      def format_id(id)
        id.to_s
      end

      def format_duration(duration)
        format = precision > 0 ? "%d:%0#{3 + precision}.#{precision}f" : "%d:%02d"
        sprintf(format, duration / 60, duration % 60)
      end

      def bold(string)
        "\e[1m#{string}\e[0m"
      end

      def feint(string)
        "\e[2m#{string}\e[0m"
      end

      def green(string)
        "\e[32m#{string}\e[0m"
      end

      def red(string)
        "\e[31m#{string}\e[0m"
      end

      def output_dir
        @output_dir ||= "/tmp"
      end

      def precision
        @precision ||= 0
      end

      def profile?
        @profile = false if @profile == nil
        @profile
      end
    end
  end
end
