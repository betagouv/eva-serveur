# frozen_string_literal: true

class BaseInputComponent < ViewComponent::Base
  def initialize(
    id:,
    label:,
    hint: nil,
    required: false,
    autocomplete: nil,
    form: nil,
    method: nil
  )
    @id = id
    @label = label
    @hint = hint
    @required = required
    @autocomplete = autocomplete
    @form = form
    @method = method
  end

  def input_id
    if use_form_builder?
      @form.object_name.present? ? "#{@form.object_name}_#{@method}" : @method.to_s
    else
      @id
    end
  end

  def messages_id
    "#{input_id}-messages"
  end

  def use_form_builder?
    @form.present? && @method.present?
  end

  def has_errors?
    return false unless use_form_builder?
    return false unless @form.object.respond_to?(:errors)

    @form.object.errors[@method].present?
  end

  def errors
    return [] unless has_errors?

    @form.object.errors[@method]
  end

  def error_html
    return "".html_safe unless has_errors?

    errors.map { |error|
      "<p class=\"fr-message fr-message--error\">#{error}</p>"
    }.join.html_safe
  end

  def is_required?
    return @required if @required == true || @required == false
    return false unless use_form_builder?
    return false unless @form.respond_to?(:required?)

    @form.required?(@method)
  end

  def required_asterisk
    return "".html_safe unless is_required?

    safe_join([ " ", tag.abbr("*", title: "required") ])
  end

  def label_classes
    classes = [ "fr-label" ]
    classes << "fr-label--error" if has_errors?
    classes.join(" ")
  end
end
