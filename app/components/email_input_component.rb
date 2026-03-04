# frozen_string_literal: true

class EmailInputComponent < ViewComponent::Base
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
    email_input_html = {
      type: "email",
      autocomplete: "email",
      placeholder: "nom@domaine.fr"
    }
    base = {
      id: id,
      label: label,
      hint: hint,
      form: form,
      method: method,
      value: value.presence,
      type: "email",
      required: required
    }
    @input_component_options = base.merge(input_component_options)
    @input_component_options[:input_html] =
      email_input_html.merge(@input_component_options[:input_html] || {})
  end
end
