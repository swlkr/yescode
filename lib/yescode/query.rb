module Yescode
  class Query
    attr_accessor :name, :sql, :statement

    def initialize(name, sql)
      @name = name
      @sql = sql
    end
  end
end
