# frozen_string_literal: true

class YesView
  extend Yescode::Strings
  include Emote::Helpers

  class << self
    attr_writer :template_path, :layout, :template_name
    attr_accessor :paths, :logger

    def template_path
      @template_path || File.join(".", "app", "views")
    end

    def layout
      @layout || "layout"
    end

    def template
      File.join(template_path, template_name)
    end

    def view(template_name)
      @template_name = template_name
    end

    def template_name
      @template_name || "#{filename}.emote"
    end
  end

  attr_accessor :csrf_name, :csrf_value, :assets, :session, :ajax

  def template
    self.class.template
  end

  def render(tmpl, params = {})
    case tmpl
    when YesView
      tmpl.csrf_name = csrf_name
      tmpl.csrf_value = csrf_value
      tmpl.session = session
      tmpl.assets = assets
      tmpl.ajax = ajax
      emote(tmpl.template, params, tmpl)
    when String
      emote(tmpl, params)
    else
      raise StandardError, "Unsupported template type passed to render"
    end
  end

  def csrf_field
    "<input type=\"hidden\" name=\"#{csrf_name}\" value=\"#{csrf_value}\" />"
  end

  def form(params = {})
    params = { method: "post" }.merge(params)
    attr_string = params.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")

    <<~HTML
      <form #{attr_string}>
        #{csrf_field}
    HTML
  end

  def _form
    "</form>"
  end

  def form_link(str, controller_name, method_name, params = {})
    <<~HTML
      #{form(action: path(controller_name, method_name, params))}
        <input type="submit" value="#{str}" />
      #{_form}
    HTML
  end

  def css
    return [] unless assets

    assets["css"].map { |filename| "/css/#{filename}" }
  end

  def js
    return [] unless assets

    assets["js"].map { |filename| "/js/#{filename}" }
  end

  def path(class_name, method_name, params = {})
    Object.const_get(:App).path(class_name, method_name, params)
  end

  def fetch(class_name, method_name, params = {})
    "<div data-href=\"#{path(class_name, method_name, params)}\"></div>"
  end
end
