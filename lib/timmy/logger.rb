module Timmy
  class Logger
    class << self
      def set_output_directory(dir)
        @output_directory = dir
      end

      def set_precision(precision)
        @precision = precision
      end

      def put_output(output)
        duration = MasterTimer.get
        formatted_duration = format_duration(duration)

        puts feint(formatted_duration) + " " + output

        @output ||= ''
        @output += sprintf("%.9f %s\n", duration, output)
      end

      def put_timer(timer)
        puts format_timer(timer)
      end

      def put_stopped_profiles
        puts "Slowest targeted timers:"

        slowest_timers = TargetedTimerManager
          .stopped
          .sort_by { |timer| -timer.duration }
          .slice(0, 10)

        slowest_timers.each do |timer|
          put_timer(timer)
        end

        puts
      end

      def finalize
        suffix = "#{MasterTimer.start.to_i}+#{MasterTimer.get.to_i}"
        filename = File.join(output_directory, "timmy-#{suffix}.log")

        File.write(filename, @output)

        puts feint("Log written to #{filename}")
        puts
      end

      private

      def format_timer(timer)
        string = "#{bold(format_duration(timer.duration))} #{format_id(timer.definition.id)}"
        string += " (#{timer.group})" if timer.group
        string += ": #{green(timer.label)}" if timer.label

        string
      end

      def format_id(id)
        id.to_s
      end

      def format_duration(duration)
        format = precision > 0 ? "%d:%0#{3 + precision}.#{precision}f" : "%d:%02d"
        sprintf(format, duration / 60, duration % 60)
      end

      def green(string)
        "\e[0m\e[32m#{string}\e[0m"
      end

      def bold(string)
        "\e[0m\e[1m#{string}\e[0m"
      end

      def feint(string)
        "\e[0m\e[2m#{string}\e[0m"
      end

      def output_directory
        @output_directory ||= "/tmp"
      end

      def precision
        @precision ||= 0
      end
    end
  end
end
