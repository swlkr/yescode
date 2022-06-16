# frozen_string_literal: true

class YesRecord
  extend Yescode::Strings

  class RecordNotFound < StandardError; end
  Column = Struct.new("Column", :name, :type, :primary_key)

  class << self
    attr_writer :table_name

    def filepath(filename)
      File.join(".", "app", "models", filename)
    end

    def define_queries(filename)
      Yescode::Queries.queries(filepath(filename)).each do |name, sql, result|
        statement = Yescode::Database.connection.prepare(sql)

        define_singleton_method name do |*params|
          Yescode::Database.logger&.debug(sql: sql, params: params)
          rows = statement.execute(*params).to_a

          case result
          when class_name
            new(rows.first) unless rows.empty?
          when "#{class_name}!"
            raise RecordNotFound unless rows.first

            new(rows.first)
          when /^Integer$/
            rows.first&.values&.first&.to_i
          when /^Integer\??$/
            value = rows.first&.values&.first
            value&.to_i if value
          when /^Float$/
            rows.first&.values&.first&.to_f
          when /^Float\??$/
            value = rows.first&.values&.first
            value&.to_f if value
          else
            rows.map { |r| new(r) }
          end
        end
      end
    end

    def table_name
      @table_name || filename
    end

    def table(name)
      @table_name = name
    end

    def schema
      @schema ||= Yescode::Database.schema[table_name]
    end

    def columns
      @columns ||= schema.map do |r|
        Column.new(
          r["columnName"],
          r["columnType"],
          r["pk"] == 1
        )
      end
    end

    def column_names
      @column_names ||= columns.map(&:name)
    end

    def primary_key_column
      @primary_key_column ||= columns.find(&:primary_key).first
    end

    def inspect
      attr_str = columns.map { |c| "  #{c.name} => #{c.type}" }.join("\n")

      "#{self} {\n#{attr_str}\n}"
    end

    def connect
      column_names.each do |column|
        attr_accessor column.to_sym
      end

      self
    end

    def values(keys)
      if keys.empty?
        "default values"
      else
        "values (#{keys.map(&:inspect).join(', ')})"
      end
    end

    def insert_sql(keys)
      "insert into #{table_name} (#{keys.join(', ')}) #{values(keys)} returning *"
    end

    def insert(params)
      params.transform_keys!(&:to_sym)
      params[:created_at] ||= Time.now.to_i if column_names.include?("created_at")
      sql = insert_sql(params.keys)
      inserted = Yescode::Database.get_first_row(sql, params)

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

      values = records.size.times.map { "(#{columns.map { '?' }.join(', ')})" }.join(", ")
      sql = "insert into '#{table_name}' (#{columns.join(', ')}) values #{values}"

      Yescode::Database.get_first_value(sql, records.map(&:values)).to_i
    end

    def update_all
      # TODO: do it
    end

    def delete_all
      Yescode::Database.get_first_value("delete from #{table_name}").to_i
    end
  end

  attr_accessor :errors

  def initialize(args = {})
    self.class.connect
    load(args)
  end

  def load(args = {})
    args.each do |k, v|
      self.class.attr_accessor(k.to_sym) unless respond_to?(k.to_sym)
      public_send("#{k}=", v)
    end
  end

  def pk_column
    self.class.primary_key_column.to_sym
  end

  def pk
    to_h[pk_column]
  end

  def pk_param
    { pk_column => pk }
  end

  def update_params(params)
    params.transform_keys!(&:to_sym)
    params[:updated_at] ||= Time.now.to_i if self.class.column_names.include?("updated_at")

    params
  end

  def update_sql(keys)
    set_clause = keys.map { |k| "#{k} = :#{k}" }.join(", ")

    "update #{self.class.table_name} set #{set_clause} where #{pk_column} = :#{pk_column} returning *"
  end

  def update(params)
    update_params = update_params(params)
    sql = update_sql(update_params.keys)
    update_params.merge!(pk_param)
    updated = Yescode::Database.get_first_row(sql, update_params)
    load(updated)

    true
  rescue SQLite3::ConstraintException => e
    Yescode::Database.logger.error(msg: e.message)
    rescue_constraint_error(e)

    false
  end

  def delete
    sql = "delete from #{self.class.table_name} where #{pk_column} = ?"
    Yescode::Database.execute(sql, pk)

    true
  end

  def check?(constraint_name)
    return false unless @errors

    @errors[:check]&.include?(constraint_name.to_s)
  end

  def null?(column_name)
    return false unless @errors

    @errors[:null]&.include?(column_name.to_s)
  end

  def duplicate?(column_name)
    return false unless @errors

    @errors[:unique]&.include?(column_name.to_s)
  end

  def error?(name)
    check?(name) || null?(name) || duplicate?(name)
  end

  def errors?
    @errors.any?
  end

  def rescue_constraint_error(error)
    message = error.message
    name = message.gsub(/(CHECK|NOT NULL|UNIQUE) constraint failed: (\w+\.)?/, '')
    @errors ||= { check: [], null: [], unique: [] }

    if message.start_with?("CHECK")
      @errors[:check] << name
    elsif message.start_with?("NOT NULL")
      @errors[:null] << name
    elsif message.start_with?("UNIQUE")
      @errors[:unique] << name
    end
  end

  def to_h
    @to_h ||= self.class.column_names.map { |c| [c.to_sym, public_send(c)] }.to_h
  end

  def saved?
    !pk.nil?
  end

  def to_param
    to_h.slice(self.class.primary_key_column.to_sym)
  end
end
