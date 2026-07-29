# frozen_string_literal: true

class NumeroTelephoneInputComponent < ViewComponent::Base
  def initialize(
    id:,
    label:,
    form: nil,
    value: nil,
    required: false,
    **input_component_options
  )
    numero_telephone_input_html = {
      autocomplete: "tel",
      inputmode: "tel"
    }
    base = {
      id: id,
      label: label,
      hint: I18n.t("numero_telephone_input.hint"),
      form: form,
      method: :telephone,
      value: value,
      type: "tel",
      required: required
    }
    @input_component_options = base.merge(input_component_options)
    @input_component_options[:input_html] =
      numero_telephone_input_html.merge(@input_component_options[:input_html] || {})
  end
end
