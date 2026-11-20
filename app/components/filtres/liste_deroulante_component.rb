module Filtres
  class ListeDeroulanteComponent < ViewComponent::Base
    def initialize(champ:, libelle:, options:, valeur: nil)
      @champ = champ
      @libelle = libelle
      @options = options
      @valeur = valeur
    end

    # default-select : activeadmin_addons transforme sinon toute liste en widget Select2
    def call
      tag.div(class: "fr-select-group") do
        label_tag("q[#{@champ}]", @libelle, class: "fr-label") +
          select_tag("q[#{@champ}]", options_for_select(@options, @valeur),
                     include_blank: t("components.filtres.toutes"),
                     class: "fr-select default-select")
      end
    end
  end
end
