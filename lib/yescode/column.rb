module Yescode
  class Column
    attr_accessor :name, :type, :primary_key

    def initialize(name, type, primary_key)
      @name = name
      @type = type
      @primary_key = primary_key
    end
  end
end
