# frozen_string_literal: true

class MiseEnAvantComponent < ViewComponent::Base
  def initialize(titre:, description: nil, icone: nil,
    classes: [], bouton_label: nil, bouton_attributes: {},
    html_attributes: {})
    @titre = titre
    @description = description
    @icone = icone
    @classes = classes
    @bouton_label = bouton_label
    @bouton_attributes = bouton_attributes
    @html_attributes = html_attributes
  end
end
