module Filtres
  class TexteComponent < ViewComponent::Base
    def initialize(champ:, libelle:, valeur: nil)
      @champ = champ
      @libelle = libelle
      @valeur = valeur
    end

    def call
      tag.div(class: "fr-input-group") do
        label_tag("q[#{@champ}]", @libelle, class: "fr-label") +
          text_field_tag("q[#{@champ}]", @valeur, class: "fr-input")
      end
    end
  end
end
