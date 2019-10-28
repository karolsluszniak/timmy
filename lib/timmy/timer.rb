module Timmy
  class Timer
    def initialize
      @start_time = current_time()
      @output = ""
      @meters = Meters.clone_all
    end

    def consume_stdin
      STDIN.each_line do |line|
        line.rstrip!

        try_start_meters(line)
        put_line(line)
        try_end_meters(line)
      end

      end_all_meters()
      finalize()
    end

    private

    def try_start_meters(line)
      @meters.each do |key, meter|
        begin_regex = meter.fetch(:begin_regex)

        if meter_start = line.match(begin_regex)
          end_meter(key) if meter.has_key?(:start_time)

          title = begin
            meter_start[:title]
          rescue IndexError
            nil
          end

          meter.merge!({
            start_time: current_time(),
            title: title
          })
        end
      end
    end

    def try_end_meters(line)
      started_meters.each do |key, meter|
        if (end_regex = meter[:end_regex]) && line.match?(end_regex)
          end_meter(key)
        end
      end
    end

    def end_all_meters
      started_meters.each do |key, _|
        end_meter(key)
      end
    end

    def end_meter(key)
      meter = @meters.fetch(key)

      start_time = meter.fetch(:start_time)
      title = meter.fetch(:title)

      log_line = key.to_s.upcase
      log_line += " #{title}" if title

      put_line(log_line, since: start_time, internal: true)

      meter.delete(:start_time)
      meter.delete(:title)
    end

    def put_line(line, since: @start_time, internal: false)
      current_time_cached = current_time()

      if internal
        @output += "#{format_duration(current_time_cached - since)} #{line}\n"
        puts "#{bold(format_duration(current_time_cached - since))} #{bold(line)}"
      else
        @output += "#{format_duration(current_time_cached - since)} | #{line}\n"
        puts "#{feint(format_duration(current_time_cached - since))} #{line}"
      end
    end

    def finalize
      total_duration = current_time() - @start_time
      suffix = "#{@start_time}+#{total_duration.round}"
      log_filename = "/tmp/timmy-#{suffix}.log"

      put_line("EOF > #{log_filename}", internal: true)
      File.write(log_filename, @output)
    end

    def format_duration(duration)
      sprintf("%d:%02d", duration / 60, duration % 60)
    end

    def bold(string)
      "\e[0m\e[1m#{string}\e[0m"
    end

    def feint(string)
      "\e[0m\e[2m#{string}\e[0m"
    end

    def current_time
      Time.now().to_i()
    end

    def started_meters
      @meters.select { |_, meter| meter.has_key?(:start_time) }
    end
  end
end
