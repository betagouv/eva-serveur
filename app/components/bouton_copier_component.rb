# frozen_string_literal: true

class BoutonCopierComponent < ViewComponent::Base
  def initialize(libelle:, texte:, classes: "", **options)
    @libelle = libelle
    @texte = texte
    @classes = classes
    @options = options
  end
end
