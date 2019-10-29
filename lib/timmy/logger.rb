module Timmy
  class Logger
    class << self
      def clear
        @output = ''
      end

      def set_output_directory(dir)
        @output_directory = dir
      end

      def set_precision(precision)
        @precision = precision
      end

      def put(line, internal: false, since: 0)
        duration = format_duration(MasterTimer.get - since)
        if internal
          @output += "#{duration} > #{line}\n"
          puts bold("#{duration} #{line}")
        else
          @output += "#{duration} | #{line}\n"
          puts feint(duration) + " " + line
        end
      end

      def finalize
        suffix = "#{MasterTimer.start.to_i}+#{(MasterTimer.get).to_i}"
        filename = File.join(output_directory, "timmy-#{suffix}.log")

        put("EOF > #{filename}", internal: true)
        File.write(filename, @output)
      end

      def format_duration(duration)
        format = precision > 0 ? "%d:%0#{3 + precision}.#{precision}f" : "%d:%02d"
        sprintf(format, duration / 60, duration % 60)
      end

      private

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
