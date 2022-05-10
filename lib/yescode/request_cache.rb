module Yescode
  module RequestCache
    def self.store
      Thread.current[:request_cache] ||= {}
    end

    def self.store=(store)
      Thread.current[:request_cache] = store
    end

    def self.clear!
      Thread.current[:request_cache] = {}
    end

    def self.begin!
      Thread.current[:request_cache_active] = true
    end

    def self.end!
      Thread.current[:request_cache_active] = false
    end

    def self.active?
      Thread.current[:request_cache_active] || false
    end

    def self.read(key)
      store[key]
    end

    def self.[](key)
      store[key]
    end

    def self.write(key, value)
      store[key] = value
    end

    def self.[]=(key, value)
      store[key] = value
    end

    def self.exist?(key)
      store.key?(key)
    end

    def self.fetch(key)
      store[key] = yield unless exist?(key)
      store[key]
    end

    def self.delete(key, &block)
      store.delete(key, &block)
    end
  end
end
