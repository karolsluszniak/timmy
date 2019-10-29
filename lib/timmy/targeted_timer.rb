module Timmy
  class TargetedTimer
    class << self
      def start_for_line(line)
        TargetedTimerDefinition.all.each do |definition|
          if match = line.match(definition.start_regex)
            stop_by_id(definition.id)
            label = match.send(:[], :label) rescue nil
            started.push(self.new(definition, label: label))
          end
        end
      end

      def stop_for_line(line)
        started.each do |timer|
          if (stop_regex = timer.definition.stop_regex) && line.match?(stop_regex)
            stop(timer)
          end
        end
      end

      def stop(timer)
        timer.stop
        started.delete(timer)
        stopped.push(timer)
      end

      def stop_by_id(id)
        matches = started.select { |timer| timer.definition.id == id }
        matches.each { |timer| stop(timer) }
      end

      def stop_all
        started.each { |timer| stop(timer) }
      end

      def started
        @started ||= []
      end

      def stopped
        @stopped ||= []
      end

      def put_stopped_profiles
        puts ""
        puts "Slowest targeted timers:"
        TargetedTimer.stopped.sort_by { |timer| -timer.duration }[0..9].each do |timer|
          timer.put_profile
        end
      end
    end

    attr_reader :definition, :label, :duration

    def initialize(definition, label: nil)
      @definition = definition
      @start_time = MasterTimer.get
      @label = label
    end

    def stop
      put
      @duration = MasterTimer.get - @start_time
    end

    def put_profile
      duration = Logger.format_duration(@duration)
      puts " - #{duration} - #{formatted_id} - #{@label}"
    end

    private

    def put
      log_line = formatted_id
      log_line += " #{@label}" if @label

      Logger.put(log_line, since: @start_time, internal: true)
    end

    def formatted_id
      @definition.id.to_s.split('_').collect(&:capitalize).join
    end
  end
end
