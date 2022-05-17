# frozen_string_literal: true

module Yescode
  class RouteNotFound < StandardError
  end

  class RouteMissing < StandardError
  end

  class RouteParamsNilError < StandardError
  end

  class NotFoundError < StandardError
  end

  class ServerError < StandardError
  end
end
