module Timmy
  class MasterTimer
    class << self
      def start(frozen_time = nil)
        @start_time = frozen_time if frozen_time
        @start_time ||= Time.now.to_f
      end

      def get
        return @frozen_duration if @frozen_duration

        Time.now.to_f - @start_time
      end

      def set(frozen_duration)
        @frozen_duration = frozen_duration
      end
    end
  end
end

