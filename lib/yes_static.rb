# frozen_string_literal: true

class YesStatic
  def initialize(app, options = {})
    @app = app
    @root = options[:root] || Dir.pwd
  end

  def call(env)
    path_info = env[Rack::PATH_INFO]
    ext = File.extname(path_info)
    return @app.call(env) if ext.empty?

    filepath = File.join(@root, path_info)

    if File.exist?(filepath)
      last_modified = File.mtime(filepath).httpdate
      return [304, {}, []] if env["HTTP_IF_MODIFIED_SINCE"] == last_modified

      [200, { "content-type" => Rack::Mime.mime_type(ext), "last-modified" => last_modified }, File.open(filepath)]
    else
      [404, {}, []]
    end
  end
end
