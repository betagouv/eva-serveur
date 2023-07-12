# frozen_string_literal: true

class RechercheStructureComponent < ViewComponent::Base
  def initialize(recherche_url: nil, structures_code_postal: nil, structures: nil,
                 current_compte: nil)
    @recherche_url = recherche_url
    @structures_code_postal = structures_code_postal
    @structures = structures
    @current_compte = current_compte
  end
end
