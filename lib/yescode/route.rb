# frozen_string_literal: true

require "yescode/request"

module Yescode
  class Route
    attr_accessor :verb, :path, :class_name, :method_name

    def initialize(verb, path, class_name, method_name)
      @verb = verb
      @path = path
      @class_name = class_name
      @method_name = method_name
    end

    def controller!(request)
      klass = Object.const_get(class_name)
      cont = klass.new(request)

      raise RouteMissing, "#{method_name} does not exist in class #{class_name}" unless cont.respond_to?(method_name)

      cont
    rescue NameError => e
      raise RouteMissing, e.message
    end
  end
end
