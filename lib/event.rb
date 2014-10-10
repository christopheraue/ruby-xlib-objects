module Xlib
  class Event
    def initialize(union)
      event = union[:type]
      union_member = Capi::EVENT_TO_UNION_MEMBER[event]
      @struct = union[union_member]

      @struct.members.each do |key|
        self.define_singleton_method(key) do
          @struct[key]
        end
      end
    end
  end
end