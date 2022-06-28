class YesTag
  SELF_CLOSING_TAGS = %w[area base br col embed hr img input keygen link meta param source track wbr].freeze

  def initialize
    self
  end

  def method_missing(name, *args, &block)
    string(name, *args, &block)
  end

  def respond_to_missing?
    true
  end

  private

  def open_tag(name, attrs)
    attr_string = attrs.empty? ? '' : " #{attribute_string(attrs)}"
    open_tag_str = "<#{name}"
    self_closing = SELF_CLOSING_TAGS.include?(name)

    "#{open_tag_str}#{attr_string}#{self_closing ? '' : '>'}"
  end

  def close_tag(name)
    self_closing = SELF_CLOSING_TAGS.include?(name)

    if self_closing
      ' />'
    else
      "</#{name}>"
    end
  end

  def attribute_string(attributes = {})
    attributes.transform_keys(&:to_s).sort_by { |k, _| k }.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
  end

  def string(name, attrs = {}, &block)
    if block
      capture(block) do
        emit open_tag(name, attrs)
        yield
        emit close_tag(name)
      end
    else
      "#{open_tag(name, attrs)}#{yield if block}#{close_tag(name)}"
    end
  end

  def emit(tag)
    @output_ ||= String.new
    @output_ << tag.to_s
  end

  def capture(block)
    @output_ = block.binding.eval('@output_') || String.new
    yield

    @output_
  end
end
