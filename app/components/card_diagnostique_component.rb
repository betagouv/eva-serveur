# frozen_string_literal: true

class CardDiagnostiqueComponent < ViewComponent::Base
  # Rails `truncate` compte la longueur totale incluant l'omission.
  OMISSION = "…"
  DESCRIPTION_TRUNCATE_AT = 75 + OMISSION.length

  def initialize(
    titre:,
    description: nil,
    bouton_label:,
    bouton_url:,
    opco: nil,
    bouton_attributes: {},
    html_attributes: {}
  )
    @titre = titre
    @description = description
    @bouton_label = bouton_label
    @bouton_url = bouton_url
    @opco = opco
    @bouton_attributes = bouton_attributes
    @html_attributes = html_attributes
  end

  def opco?
    @opco.present?
  end

  def description_affichee
    return if @description.blank?

    @description.to_s.truncate(DESCRIPTION_TRUNCATE_AT, omission: OMISSION)
  end
end
