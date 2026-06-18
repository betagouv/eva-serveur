# frozen_string_literal: true

class PasswordInputComponent < BaseInputComponent
  def initialize(id:, label:, hint: nil, form: nil, method: nil, required: false, autocomplete: nil)
    super(id: id, label: label, hint: hint, form: form, method: method,
          required: required, autocomplete: autocomplete)
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
end
