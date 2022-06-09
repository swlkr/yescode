# Copyright (c) 2011 Michel Martens
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

require "cgi/escape"

module Yescode
  class Emote
    PATTERN = /
      ^[^\S\n]*(%)[^\S\n]*(.*?)(?:\n|\Z) | # Ruby evaluated lines
      (<\?)\s+(.*?)\s+\?>                | # Multiline Ruby blocks
      (\$\{)(.*?)\}                      | # Ruby evaluated to strings unescaped
      (\{\{)(.*?)\}\}                      # Ruby evaluated to strings html escaped
    /mx

    def self.h(value)
      CGI.escapeHTML(value.to_s)
    end

    def self.src(template)
      terms = template.split(PATTERN)

      code = "proc do |__o| __o ||= '';"

      while (term = terms.shift)
        code << case term
                when "<?"
                  "#{terms.shift}\n"
                when "%"
                  "#{terms.shift}\n"
                when "${"
                  "__o << (#{terms.shift}).to_s\n"
                when "{{"
                  "__o << Emote.h(#{terms.shift}).to_s\n"
                else
                  "__o << #{term.dump}\n"
                end
      end

      code << "__o; end"
    end

    def self.parse(template, context, name)
      context.instance_eval(src(template), name, -1)
    end

    module Helpers
      def emote(filename, context)
        key = filename.hash + context.hash
        file_cache[filename] ||= File.read(filename)
        emote_cache[key] ||= Emote.parse(file_cache[filename], context, filename)

        emote_cache[key][]
      end

      def emote_cache
        Thread.current[:_emote_cache] ||= {}
      end

      def file_cache
        Thread.current[:_file_cache] ||= {}
      end
    end
  end
end
