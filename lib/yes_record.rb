# frozen_string_literal: true

class YesRecord
  include Yescode::Schema
  include Yescode::Constraints
  include Yescode::Persistence
  include YesQueries
end
