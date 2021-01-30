module VNS
  class Session
    attr_reader :id, :name

    def initialize(id, name)
      @id = id
      @name = name
    end

    def to_s
      "#{id}\t#{name}"
    end
  end
end
