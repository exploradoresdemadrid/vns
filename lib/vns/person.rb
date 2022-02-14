module VNS
  class Person
    attr_reader :id, :name, :group
    def initialize(id, name, group)
      @id = id
      @name = name
      @group = group
    end

    def to_s
      "#{id}\t#{name} (#{group})"
    end
  end
end