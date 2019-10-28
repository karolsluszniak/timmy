module Timmy
  class ConfigLoader
    class << self
      def load
        home = Dir.home()
        config = File.join(home, ".timmy.rb")

        if File.exists?(config)
          eval(File.read(config))
        end
      end
    end
  end
end
