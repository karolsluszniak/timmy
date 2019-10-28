module Timmy
  class Meters
    BUILTIN = {
      docker_build_step: {
        begin_regex: /Step \d+\/\d+ : (?<title>.*)$/,
        end_regex: / ---> [0-9a-f]{12}$/
      }
    }

    class << self
      def add(key, begin_regex:, end_regex: nil)
        meters[key] = { begin_regex: begin_regex, end_regex: end_regex }
      end

      def clone_all
        Marshal.load(Marshal.dump(meters))
      end

      def meters
        @meters ||= BUILTIN
      end
    end
  end
end
