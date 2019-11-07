require 'open3'
require 'thread'

module Timmy
  class CommandStreamer
    class << self
      def stream(command, &block)
        self.new(command).stream(&block)
      end
    end

    def initialize(command)
      @command = command
      @queue = Queue.new
    end

    def stream(&block)
      Open3.popen3(*@command) do |stdin, stdout, stderr, wait_thr|
        start_readers(stdout: stdout, stderr: stderr)
        pop_lines_from_active_readers(block)
        join_readers()
      end
    end

    private

    def start_readers(streams)
      @readers = streams.map do |type, stream|
        thread = Thread.new do
          until (line = stream.gets).nil? do
            @queue << [type, line]
          end
          @queue << [type, nil]
        end

        [type, thread]
      end.to_h

      @active_readers = @readers.keys
    end

    def pop_lines_from_active_readers(delegate)
      while @active_readers.any? do
        type, line = @queue.pop

        if line
          delegate.call(type, line)
        else
          @active_readers.delete(type)
        end
      end
    end

    def join_readers
      @readers.values.each(&:join)
    end
  end
end
