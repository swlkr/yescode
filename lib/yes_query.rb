# frozen_string_literal: true

module YesQuery
  extend Yescode::Strings

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def select(params = {})
      query(params).map { |row| new(**row) }
    end

    def first(params = {})
      select(params).first
    end

    def value(params = {})
      query(params).first&.values&.first
    end

    def query(params)
      statement.execute(params || {}).to_a
    end

    def sql
      File.read("#{filename}.sql")
    end

    def statement
      Yescode::Database.connection.prepare(sql)
    end
  end
end
