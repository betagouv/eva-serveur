# frozen_string_literal: true

class PasswordInputComponent < ViewComponent::Base
  def initialize(id:, label:, hint: nil, form: nil, method: nil, required: false, autocomplete: nil)
    @id = id
    @label = label
    @hint = hint
    @form = form
    @method = method
    @required = required
    @autocomplete = autocomplete
  end

  def input_id
    if @form&.object_name.present? && @method.present?
      "#{@form.object_name}_#{@method}"
    else
      @id
    end
  end

  def messages_id
    "#{input_id}-messages"
  end

  def show_id
    "#{input_id}-show"
  end

  def input_attributes
    attrs = {
      class: "fr-password__input fr-input",
      id: input_id,
      type: "password",
      autocapitalize: "off",
      autocorrect: "off",
      "aria-describedby" => messages_id
    }
    attrs[:required] = true if @required
    attrs[:autocomplete] = @autocomplete if @autocomplete.present?
    attrs
  end

  def has_errors?
    return false unless @form&.object.respond_to?(:errors)

    @form.object.errors[@method].present?
  end

  def error_html
    return "".html_safe unless has_errors?

    @form.object.errors[@method].map { |error|
      "<p class=\"fr-message fr-message--error\">#{error}</p>"
    }.join.html_safe
  end

  def label_classes
    classes = [ "fr-password__label", "fr-label" ]
    classes << "fr-label--error" if has_errors?
    classes.join(" ")
  end

  def required_asterisk
    return "".html_safe unless @required

    safe_join([ " ", tag.abbr("*", title: "required") ])
  end
end
