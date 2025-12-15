class FileInput < Formtastic::Inputs::FileInput
  def to_html
    input_wrapping do
      label_html <<
      file_input_html <<
      messages_wrapping
    end
  end

  private

  def wrapper_classes
    classes = super
    classes += " fr-upload-group"
    classes += " fr-upload-group--error" if has_errors?
    classes
  end

  def label_html
    label_content = label_text.html_safe

    template.content_tag(:label,
      label_content,
      class: "fr-label",
      for: input_id
    )
  end

  def file_input_html
    input_html = get_input_html_options

    builder.file_field(
      method,
      input_html
    )
  end

  def get_input_html_options
    input_html = input_html_options.dup
    input_html[:id] ||= input_id
    input_html["aria-describedby"] = messages_id if has_errors? || hint_text.present?
    input_html[:required] = true if required?
    input_html[:class] = [ input_html[:class], "fr-upload" ].compact.join(" ")
    input_html
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

  def hint_html
    if hint?
      template.content_tag(
        :span,
        hint_text.html_safe,
        class: builder.default_hint_class + " fr-hint-text"
      )
    end
  end

  def hint_text
    return nil unless options[:hint].present?
    options[:hint].is_a?(String) ? options[:hint] : nil
  end
end
