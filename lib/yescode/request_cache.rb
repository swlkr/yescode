# Copyright (c) 2012 Steve Klabnik
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
