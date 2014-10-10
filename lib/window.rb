module Xlib
  class Window
    class << self
      def new(screen, window_id)
        @windows ||= {}
        @windows[window_id] = super
      end

      def get(window_id)
        @windows[window_id]
      end
    end

    attr_reader :screen

    def initialize(screen, window_id)
      @screen = screen
      @native = window_id
      @event_mask = 0
      @event_handler = {}
    end

    def to_native
      @native
    end

    def left
      attributes[:x]
    end

    def top
      attributes[:y]
    end

    def width
      attributes[:width]
    end

    def height
      attributes[:height]
    end

    def mapped?
      attributes[:map_state] != 'IsUnmapped'
    end

    def visible?
      attributes[:map_state] == 'IsViewable'
    end

    def display
      screen.display
    end

    def property(name)
      Property.get(self, name)
    end

    def properties
      Property.all(self)
    end

    def listen_to(event_mask)
      raise "Unknown event #{event_mask}." unless Capi::EVENT_MASK[event_mask]

      @event_mask |= Capi::EVENT_MASK[event_mask]
      Xlib::Capi.XSelectInput(display.to_native, self.to_native, @event_mask)
      self
    end

    def turn_deaf_on(event_mask)
      raise "Unknown event #{event_mask}." unless Capi::EVENT_MASK[event_mask]

      @event_mask &= ~Capi::EVENT_MASK[event_mask]
      Xlib::Capi.XSelectInput(display.to_native, self.to_native, @event_mask)
      self
    end

    def on(event_name, &block)
      raise "Unknown event #{event_name}." unless Capi::EVENT[event_name]

      @event_handler[Capi::EVENT[event_name]] = block
      self
    end

    def handle(event)
      @event_handler[event.type].call(event) if @event_handler[event.type]
    end

    private
    def attributes
      attributes = Capi::WindowAttributes.new
      Capi::XGetWindowAttributes(display.to_native, self.to_native, attributes.pointer)
      attributes
    end
  end
end