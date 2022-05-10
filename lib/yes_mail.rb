Mail.defaults do
  delivery_method :logger, logger: Logger.new($stdout) if Yescode.env.development?
end

class YesMail
  using Refinements
  include Emote::Helpers

  class << self
    attr_writer :template_path
    attr_accessor :_from, :_layout, :_html_view, :_text_view

    def template_path
      @template_path || File.join(".", "app", "emails")
    end

    def layout(arg)
      @_layout = arg
    end

    def from(arg)
      @_from = arg
    end

    def html_view(arg)
      @_html_view = arg
    end

    def text_view(arg)
      @_text_view = arg
    end

    def inherited(subclass)
      subclass._from = @_from
      subclass._layout = @_layout
      subclass._html_view = @_html_view
      subclass._text_view = @_text_view
      super
    end
  end

  def deliver
    raise NotImplementedError
  end

  def mail(from: nil, to: nil, subject: nil)
    mail = Mail.new
    mail[:from] = from || self.class._from
    mail[:to] = to
    mail[:subject] = subject

    default_name = self.class.to_s.snake_case

    text = part(self.class._text_view || "#{default_name}.text.emote")
    html = part(self.class._html_view || "#{default_name}.html.emote")

    text_part = Mail::Part.new do
      body text
    end

    html_part = Mail::Part.new do
      content_type "text/html; charset=UTF-8"
      body html
    end

    mail.text_part = text_part
    mail.html_part = html_part

    mail.deliver
  end

  private

  def template(name)
    File.join(self.class.template_path, name)
  end

  def part(name)
    content = template(name)
    layout = template(self.class._layout || "layout")

    if File.exist?(layout)
      emote(layout, { content: })
    else
      emote(content)
    end
  end
end
