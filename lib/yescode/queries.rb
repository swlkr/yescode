module Yescode
  class Queries
    class << self
      def name(line)
        line.match(/^--\s*name\s*:\s*(\S+)/).to_a.last
      end

      def sql(line)
        line.match(/^[^-{2}](.*)/).to_a.first
      end

      def result(line)
        line.match(/->\s+(function|first!?)$/).to_a.last
      end

      def queries(filename)
        queries = []

        File.foreach filename do |line|
          query_name = name(line)
          query_sql = sql(line)
          query_result = result(line)

          queries << [query_name.to_sym, ""] if query_name
          queries.last[1] = "#{queries.last[1]} #{query_sql}".strip if query_sql
          queries.last[2] = query_result if query_result
        end

        queries
      end
    end
  end
end
