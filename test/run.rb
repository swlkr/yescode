require_relative "../lib/yescode"

Dir["#{__dir__}/**/test_*.rb"].each do |path|
  require path
end
