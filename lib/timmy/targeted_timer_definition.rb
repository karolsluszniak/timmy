module Timmy
  class TargetedTimerDefinition
    class << self
      def add(id, start_regex:, stop_regex: nil)
        all.push(self.new(id, start_regex: start_regex, stop_regex: stop_regex))
      end

      def all
        @all ||= [
          self.new(:docker_build,
            start_regex: /Step \d+\/\d+ : (?<label>.*)$/,
            stop_regex: / ---> [0-9a-f]{12}$/)
        ]
      end
    end

    attr_reader :id, :start_regex, :stop_regex

    def initialize(id, start_regex:, stop_regex: nil)
      @id = id

      @start_regex = start_regex
      @stop_regex = stop_regex
    end
  end
end
