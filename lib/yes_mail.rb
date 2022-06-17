# frozen_string_literal: true

Mail.defaults do
  delivery_method :logger, logger: Logger.new($stdout) if Yescode.env.development? || Yescode.env.test?
end

class YesMail
  extend Yescode::Strings

  class << self
    attr_writer :template_path
    attr_accessor :_from, :_layout, :_html_view, :_text_view, :content

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
    new_mail(from:, to:, subject:).deliver
  end

  private

  def template(name)
    File.join(self.class.template_path, name)
  end

  def part(name)
    @content = template(name)
    layout = template(self.class._layout || "layout")

    return unless File.exist?(layout) || File.exist?(@content)

    if File.exist?(layout)
      instance_eval(Erubi::Engine.new(layout, escape: true, freeze: true).src)
    else
      instance_eval(Erubi::Engine.new(@content, escape: true, freeze: true).src)
    end
  end

  def new_mail(from:, to:, subject:)
    mail = Mail.new
    mail[:from] = from || self.class._from
    mail[:to] = to
    mail[:subject] = subject

    filename = self.class.filename

    text = part(self.class._text_view || "#{filename}.text.erb")
    html = part(self.class._html_view || "#{filename}.html.erb")

    if text
      mail.text_part = Mail::Part.new do
        body text
      end
    end

    if html
      mail.html_part = Mail::Part.new do
        content_type "text/html; charset=UTF-8"
        body html
      end
    end

    mail
  end
end
