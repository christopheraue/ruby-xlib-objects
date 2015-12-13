module XlibObj
  class Event::Mask
    def initialize
      @mask = 0
    end

    attr_reader :mask

    def add(mask)
      @mask |= mask
    end

    def subtract(mask)
      @mask &= ~mask
    end
  end
end