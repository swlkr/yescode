# frozen_string_literal: true

module Yescode
  module Persistence
    include Constraints

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      include Schema
      # TODO: upsert

      def insert(params)
        columns = params.keys.map(&:to_sym)
        values = if columns.empty?
                   "default values"
                 else
                   "values (#{columns.map(&:inspect).join(', ')})"
                 end
        sql = "insert into '#{table_name}' (#{columns.join(', ')}) #{values} returning *"
        inserted = Yescode::Database.get_first_row(sql, params)
        raise StandardError, "First inserted row could not be found" unless inserted

        new(inserted)
      rescue SQLite3::ConstraintException => e
        Yescode::Database.logger.error(msg: e.message)

        record = new(params)
        record.rescue_constraint_error(e)

        record
      end

      def insert_all(records)
        return 0 if records.nil? || records&.compact&.empty?

        columns = records&.first&.keys&.compact&.map(&:to_sym)
        return 0 if columns.nil? || columns.empty?

        values = records.size.times.map { "(#{columns.map(&:inspect).join(', ')})" }.join(", ")
        sql = "insert into '#{table_name}' (#{columns.join(', ')}) values #{values}"
        Yescode::Database.get_first_value(sql, records).to_i
      end

      # TODO: update_all

      def delete_all
        Yescode::Database.get_first_value("delete from '#{table_name}'")&.to_i
      end
    end
  end
end
