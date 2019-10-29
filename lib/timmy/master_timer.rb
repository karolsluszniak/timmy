module Timmy
  class MasterTimer
    class << self
      def start(time = nil)
        @start_time = time if time
        @start_time ||= Time.now.to_f
      end

      def get
        return @duration if @duration
        Time.now.to_f - @start_time
      end

      def set(duration)
        @duration = duration
      end
    end
  end
end

