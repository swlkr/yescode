module Yescode
  module Constraints
    attr_accessor :errors

    def check?(constraint_name)
      return false unless @errors&.dig(:check)

      @errors[:check].include?(constraint_name.to_s)
    end

    def null?(column_name)
      return false unless @errors&.dig(:null)

      @errors[:null].include?(column_name.to_s)
    end

    def duplicate?(column_name)
      return false unless @errors&.dig(:unique)

      @errors[:unique].include?(column_name.to_s)
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
  end
end
