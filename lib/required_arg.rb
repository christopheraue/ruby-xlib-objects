module XlibObj
  class RequiredArg
    def initialize(name = nil)
      msg = name.nil? ? "missing keyword" : "missing keyword: #{name}"
      raise ArgumentError, msg
    end
  end
end
