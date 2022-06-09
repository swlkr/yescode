module YesRow
  include Yescode::Constraints

  def update(params)
    update_params = update_params(params)
    sql = update_sql(update_params.keys)
    update_params.merge!(self.class.primary_key_column => primary_key)
    updated = Yescode::Database.get_first_row(sql, update_params)
    raise StandardError, "Updated row could not be found" unless updated

    updated.each do |k, v|
      public_send("#{k}=", v)
    end

    true
  rescue SQLite3::ConstraintException => e
    Yescode::Database.logger.error(msg: e.message)
    rescue_constraint_error(e)

    false
  end

  def delete
    sql = "delete from #{self.class.table_name} where #{self.class.primary_key_column} = ?"
    Yescode::Database.execute(sql, primary_key)

    true
  end

  def saved?
    !primary_key.nil?
  end

  def to_param
    { self.class.primary_key_column => primary_key }
  end

  private

  def update_params(params)
    params.transform_keys!(&:to_sym)
    params[:updated_at] ||= Time.now.to_i if respond_to?(:updated_at=)

    params
  end

  def update_sql(keys)
    set_clause = keys.map { |k| "#{k} = :#{k}" }.join(", ")

    "update #{self.class.table_name} set #{set_clause} where #{self.class.primary_key_column} = :#{self.class.primary_key_column} returning *"
  end
end
