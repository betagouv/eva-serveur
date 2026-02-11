# frozen_string_literal: true

class CardDiagnostiqueComponent < ViewComponent::Base
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
end
