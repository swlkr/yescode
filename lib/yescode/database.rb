# frozen_string_literal: true

module Yescode
  class Database
    class << self
      attr_writer :connection_string
      attr_accessor :logger

      def connection_string
        @connection_string || ENV["DATABASE_URL"]
      end

      def connection
        @connection ||= SQLite3::Database.new(connection_string, { results_as_hash: true })
      end

      def version(filename)
        File.basename(filename).split("_").first.to_i
      end

      def migrate(filenames)
        return unless connection_string

        execute "create table if not exists yescode_migrations ( version integer primary key )"
        rows = execute("select version from yescode_migrations").map { |r| r["version"] }
        file_versions = filenames.map { |f| version(f) }

        return if (file_versions - rows).empty?

        transaction do
          filenames.each do |filename|
            version = version(filename)
            next if rows.include?(version)

            queries = Queries.queries(filename)
            query = queries.find { |name, _| name == :up }&.last
            next unless query

            execute(query)
            execute("insert into yescode_migrations (version) values (?)", [version])
          end
        end
      end

      def rollback_schema(filenames, step:)
        return unless connection_string

        execute "create table if not exists yescode_migrations ( version integer primary key )"
        rows = execute("select version from yescode_migrations order by version desc limit ?", [step])
        rows = rows.map { |r| r["version"] }

        return if rows.empty?

        transaction do
          rows.each do |row|
            filename = filenames.find { |f| version(f) == row }
            raise StandardError, "Sql file for rollback version #{row} not found" unless filename

            version = version(filename)
            next unless rows.include?(version)

            queries = Queries.queries(filename)
            query = queries.find { |name, _| name == :down }&.last
            next unless query

            execute(query)
            execute("delete from yescode_migrations where version = ?", [version])
          end
        end
      end

      def transaction(mode = :deferred)
        return yield(connection) if connection.transaction_active?

        execute "begin #{mode} transaction"
        @abort = false
        yield self

        true
      rescue StandardError
        @abort = true
        raise
      ensure
        if @abort
          execute "rollback transaction"
        else
          execute "commit transaction"
        end
      end

      def rollback
        @abort = true
      end

      def execute(sql, params = nil)
        logger&.debug(sql: sql, params: params)

        connection.execute(sql, params)
      end

      def get_first_value(sql, params = nil)
        logger&.debug(sql: sql, params: params)

        connection.get_first_value(sql, params)
      end

      def get_first_row(sql, params = nil)
        logger&.debug(sql: sql, params: params)

        connection.get_first_row(sql, params)
      end

      def schema
        return @schema if @schema

        sql = <<-SQL
          select
            m.name as tableName,
            pti.name as columnName,
            pti.type as columnType,
            pti.pk as pk
          from
            sqlite_master m
          left outer join
            pragma_table_info(m.name) pti on pti.name <> m.name
          where
            m.type == 'table'
          order by
            tableName,
            columnName
        SQL

        rows = Database.execute sql

        @schema = rows.group_by do |r|
          r["tableName"]
        end
      end
    end

    if connection_string && connection
      execute "PRAGMA journal_model = WAL"
      execute "PRAGMA foreign_keys = ON"
      execute "PRAGMA busy_timeout = 5000"
      execute "PRAGMA synchronous = NORMAL"
      execute "PRAGMA wal_autocheckpoint = 0"
      schema
    end
  end
end
