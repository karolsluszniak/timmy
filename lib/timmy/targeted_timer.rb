module Timmy
  class TargetedTimer
    attr_reader :definition, :label, :group, :start_time, :duration

    def initialize(definition, label: nil, group: nil)
      @definition = definition
      @label = label
      @group = group
      @start_time = MasterTimer.get
    end

    def stop
      @duration = MasterTimer.get - @start_time
    end
  end
end
