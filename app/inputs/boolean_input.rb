class BooleanInput < Formtastic::Inputs::BooleanInput
  def to_html
    input_wrapping do
      checkbox_group_wrapping do
        checkbox_input <<
        checkbox_label <<
        messages_wrapping
      end
    end
  end

  private

  def checkbox_group_wrapping(&block)
    template.content_tag(:div,
      template.capture(&block).html_safe,
      class: "fr-checkbox-group fr-checkbox-group--sm"
    )
  end

  def checkbox_input
    input_html = get_input_html_options

    hidden_field_for_checkbox <<
    template.check_box_tag(
      input_html_options_name,
      checked_value,
      checked?,
      input_html
    )
  end

  def get_input_html_options
    input_html = input_html_options.dup
    input_html[:id] ||= input_id
    input_html["aria-describedby"] = messages_id if has_errors? || hint_text.present?
    input_html[:required] = true if required?
    input_html
  end

  def checkbox_label
    label_content = label_text.html_safe
    hint = hint_text
    label_content << hint_span(hint) if hint.present?

    template.content_tag(:label,
      label_content,
      class: "fr-label",
      for: input_id
    )
  end

  def hint_span(hint)
    template.content_tag(:span,
      hint.html_safe,
      class: "fr-hint-text"
    )
  end

  def hint_text
    return nil unless options[:hint].present?
    options[:hint].is_a?(String) ? options[:hint] : nil
  end

  def input_id
    input_html_options[:id] || "#{builder.object_name}_#{method}"
  end

  def messages_id
    "#{input_id}-messages"
  end

  def messages_wrapping
    template.content_tag(:div,
      error_html.html_safe,
      class: "fr-messages-group",
      id: messages_id,
      "aria-live" => "polite"
    )
  end

  def error_html
    return "" unless has_errors?
    errors.map { |error|
      template.content_tag(:p, error, class: "fr-message fr-message--error")
    }.join.html_safe
  end

  def has_errors?
    object && object.respond_to?(:errors) && object.errors[method].present?
  end

  def errors
    return [] unless has_errors?
    object.errors[method]
  end

  def checked_value
    options[:checked_value] || "1"
  end

  def unchecked_value
    options[:unchecked_value] || "0"
  end

  def hidden_field_for_checkbox
    template.hidden_field_tag(
      input_html_options_name,
      unchecked_value,
      id: nil,
      disabled: input_html_options[:disabled]
    )
  end

  def input_html_options_name
    if builder.options.key?(:index)
      "#{builder.object_name}[#{builder.options[:index]}][#{method}]"
    else
      "#{builder.object_name}[#{method}]"
    end
  end

  def checked?
    object && boolean_checked?(object.send(method), checked_value)
  end

  def boolean_checked?(value, checked_value)
    case value
    when TrueClass, FalseClass
      value
    when NilClass
      false
    when Integer
      value == checked_value.to_i
    when String
      value == checked_value
    when Array
      value.include?(checked_value)
    else
      value.to_i != 0
    end
  end
end
