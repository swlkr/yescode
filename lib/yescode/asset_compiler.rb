# frozen_string_literal: true

module Yescode
  class AssetCompiler
    class << self
      def compile(assets, ext)
        # read contents of each file into array of strings
        combined = StringIO.open do |s|
          assets.each do |filename|
            source = File.join(".", "app", ext, filename)
            s.puts File.read(source)
          end

          s.string
        end

        # hash the contents of each concatenated asset
        hash = Digest::SHA1.hexdigest combined

        # use hash to bust the cache
        name = "#{hash}.#{ext}"
        filename = File.join(".", "public", ext, name)
        FileUtils.mkdir_p(File.join(".", "public", ext))

        # output asset path for browser
        # returns string of written filename
        File.write(filename, combined)

        # returns a one element array of
        # filenames so the view can call .each
        [name]
      end
    end
  end
end
