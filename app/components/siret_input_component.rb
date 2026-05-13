# frozen_string_literal: true

class SiretInputComponent < ViewComponent::Base
  # Utilise le lien Annuaire des Entreprises par défaut si link_url non fourni.
  def initialize(
    id:,
    label:,
    hint: nil,
    form: nil,
    method: nil,
    value: nil,
    required: true,
    link_text: nil,
    link_url: SiretInput::ANNUAIRE_SIRET_URL_CAMPAGNE_PRO_CONNECT,
    link_html: nil,
    **input_component_options
  )
    default_link_html = { target: "_blank", rel: "noopener noreferrer" }
    siret_input_html = {
      "data-siret-input" => "true",
      maxlength: 18, # 14 chiffres + 4 espaces (format 3-3-3-5)
      inputmode: "numeric",
      autocomplete: "off"
    }
    base = {
      id: id,
      label: label,
      hint: hint,
      form: form,
      method: method,
      value: FormatageSiretHelper.formater_siret(value),
      type: "text",
      required: required,
      placeholder: "123 456 789 01234",
      pattern: "[0-9\\s]*",
      link_text: link_text,
      link_url: link_url,
      link_html: link_html || default_link_html
    }
    @input_component_options = base.merge(input_component_options)
    @input_component_options[:input_html] =
      siret_input_html.merge(@input_component_options[:input_html] || {})
  end
end
