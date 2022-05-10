# frozen_string_literal: true

class YesLogger < Logger
  def initialize(*)
    super
    @formatter = Yescode::LogfmtFormatter.new
  end
end
