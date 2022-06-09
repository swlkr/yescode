# frozen_string_literal: true

module Yescode
  module Schema
    include Strings

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def table_name
        filename
      end

      def primary_key_column
        "#{table_name}_id"
      end

      def schema
        Database.schema[table_name]
      end

      def columns
        schema.map { |r| Column.new(r["columnName"], r["columnType"], r["pk"] == 1) }
      end

      def inspect
        attr_str = columns.map { |c| "  #{c.name} => #{c.type.downcase}" }.join("\n")

        "#{self} {\n#{attr_str}\n}"
      end
    end
  end
end
