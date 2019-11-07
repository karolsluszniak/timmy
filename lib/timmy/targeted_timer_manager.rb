module Timmy
  class TargetedTimerManager
    class << self
      def start_for_line(line)
        TargetedTimerDefinition.all.each do |definition|
          if match = match_line(line, definition.start_regex)
            label = get_capture(match, :label)
            group = get_capture(match, :group)

            stop_by_id_and_group(definition.id, group)
            started.push(TargetedTimer.new(definition, label: label, group: group))
          end
        end
      end

      def stop_for_line(line)
        started.each do |timer|
          if (stop_regex = timer.definition.stop_regex) &&
             (match = match_line(line, stop_regex)) &&
             get_capture(match, :group) == timer.group
            stop(timer)
          end
        end
      end

      def stop(timer)
        timer.stop
        Logger.put_timer(timer)

        started.delete(timer)
        stopped.push(timer)
      end

      def stop_by_id_and_group(id, group)
        matches = started
          .select { |timer| timer.definition.id }
          .select { |timer| timer.group == group }

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

      private

      def match_line(line, regex)
        line.gsub(/(\x1b\[[0-9;]*m)/, '').match(regex)
      end

      def get_capture(match, name)
        match[name]
      rescue IndexError
        nil
      end
    end
  end
end
