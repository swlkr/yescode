module YesQueries
  class RecordNotFound < StandardError; end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def queries
      return @queries if defined?(@queries)

      filepath = File.join(".", "app", "models", "#{self}.sql")
      queries = Yescode::Queries.queries(filepath)

      @queries = queries.map { |name, sql| [name, Yescode::Query.new(name, sql)] }.to_h
    end

    def select(name, *params)
      execute(name, params).map { |row| new(**row) }
    end

    def first(name, *params)
      select(name, params).first
    end

    def first!(name, *params)
      row = first(name, params)

      raise RecordNotFound if row.nil?

      new(row)
    end

    def value(name, *params)
      statement(name).execute(params || {}).first&.values&.first
    end

    def execute(name, params)
      statement(name).execute(params || {}).to_a
    end

    def statement(name)
      @statement ||= Yescode::Database.connection.prepare(queries[name])
    end
  end
end
