class YesTag
  def a(html, attrs = {})
    tag("a", html, attrs)
  end

  def span(html, attrs = {})
    tag("span", html, attrs)
  end

  def input(attrs = {})
    self_close_tag("input", attrs)
  end

  def tag(name, html, attrs = {})
    "<#{name} #{html_attribute_string(attrs)}>#{html}</#{name}>"
  end

  def self_close_tag(name, attrs = {})
    "<#{name} #{html_attribute_string(attrs)} />"
  end

  private

  def html_attribute_string(attributes)
    attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")
  end
end
