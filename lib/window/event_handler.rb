class CappX11::Window::EventHandler
  def initialize(window)
    @window = window
    @event_handlers = {}
    @event_mask = 0
  end

  def on(mask, event, &handler)
    add_event_mask(mask)
    add_event_handler(mask, event, &handler)
  end

  def off(mask, type, handler)
    remove_event_handler(mask, type, handler)
    remove_event_mask(mask)
  end

  def handle(event)
    if @event_handlers[event.type]
      @event_handlers[event.type].each do |_, handlers|
        handlers.each{ |handler| handler.call(event) }
      end
    end
  end
  
  private
  def add_event_mask(mask)
    check_event_mask(mask)
    return if mask_in_use?(mask)
    @event_mask |= X11::Xlib::EVENT_MASK[mask]
    select_events
  end

  def remove_event_mask(mask)
    check_event_mask(mask)
    return if mask_in_use?(mask)
    @event_mask &= ~X11::Xlib::EVENT_MASK[mask]
    select_events
  end

  def add_event_handler(mask, event, &handler)
    check_event(event)
    event_id = X11::Xlib::EVENT[event]
    @event_handlers[event_id] ||= {}
    @event_handlers[event_id][mask] ||= []
    @event_handlers[event_id][mask] << handler
    handler
  end

  def remove_event_handler(mask, event, handler)
    check_event(event)
    event_id = X11::Xlib::EVENT[event]
    @event_handlers[event_id][mask].delete(handler)
    @event_handlers[event_id].delete(mask) if @event_handlers[event_id][mask].empty?
    @event_handlers.delete(event_id) if @event_handlers[event_id].empty?
  end

  def mask_in_use?(mask)
    not @event_handlers.select do |_, handlers|
      handlers.has_key?(mask)
    end.empty?
  end
  
  def check_event_mask(mask)
    raise "Unknown event #{mask}." unless X11::Xlib::EVENT_MASK[mask]
  end
  
  def check_event(event)
    raise "Unknown event #{event}." unless X11::Xlib::EVENT[event]
  end
  
  def select_events
    X11::Xlib.XSelectInput(display.to_native, window.to_native, @event_mask)
    X11::Xlib.XFlush(display.to_native)
  end
  
  def display
    @window.display
  end
  
  def window
    @window
  end
end