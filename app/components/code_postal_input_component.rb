# frozen_string_literal: true

class CodePostalInputComponent < ViewComponent::Base
  CODE_POSTAL_LENGTH = 5

  def initialize(
    id:,
    label:,
    hint: nil,
    form: nil,
    method: nil,
    value: nil,
    required: true,
    **input_component_options
  )
    code_postal_input_html = {
      "data-code-postal-input" => "true",
      maxlength: CODE_POSTAL_LENGTH,
      inputmode: "numeric",
      autocomplete: "postal-code",
      pattern: "[0-9]*",
      placeholder: "75001"
    }
    base = {
      id: id,
      label: label,
      hint: hint,
      form: form,
      method: method,
      value: normalized_value(value),
      type: "text",
      required: required
    }
    @input_component_options = base.merge(input_component_options)
    @input_component_options[:input_html] =
      code_postal_input_html.merge(@input_component_options[:input_html] || {})
  end

  private

  def normalized_value(raw)
    return nil if raw.blank?
    return nil if raw.to_s == StructureLocale::TYPE_NON_COMMUNIQUE

    digits = raw.to_s.gsub(/\D/, "")[0, CODE_POSTAL_LENGTH]
    digits.presence
  end
end
