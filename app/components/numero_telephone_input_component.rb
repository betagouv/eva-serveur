# frozen_string_literal: true

class NumeroTelephoneInputComponent < ViewComponent::Base
  def initialize(
    id:,
    label:,
    hint: nil,
    form: nil,
    method: nil,
    value: nil,
    required: false,
    **input_component_options
  )
    numero_telephone_input_html = {
      "data-numero-telephone-input" => "true",
      type: "tel",
      autocomplete: "tel",
      inputmode: "tel",
      placeholder: "(+33) 1 22 33 44 55"
    }
    base = {
      id: id,
      label: label,
      hint: hint,
      form: form,
      method: method,
      value: FormatageNumeroTelephone.formater(value),
      type: "tel",
      required: required
    }
    @input_component_options = base.merge(input_component_options)
    @input_component_options[:input_html] =
      numero_telephone_input_html.merge(@input_component_options[:input_html] || {})
  end
end
