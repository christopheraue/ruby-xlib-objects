module CappX11
  class Event
    def initialize(union)
      event = union[:type]
      union_member = X11::Xlib::EVENT_TO_UNION_MEMBER[event]
      @struct = union[union_member]

      @struct.members.each do |key|
        self.define_singleton_method(key) do
          @struct[key]
        end
      end
    end

    def method_missing(method_name)
      nil
    end
  end
end