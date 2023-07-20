# frozen_string_literal: true

class RechercheStructureComponent < ViewComponent::Base
  def initialize(recherche_url: nil, current_compte: nil,
                 ville_ou_code_postal: nil, code_postal: nil)
    @recherche_url = recherche_url
    @current_compte = current_compte
    @ville_ou_code_postal = ville_ou_code_postal
    @code_postal = code_postal
    @button_disabled = true

    return if ville_ou_code_postal.blank?

    @button_disabled = false
    @structures_code_postal = StructureLocale.where(code_postal: code_postal)
    @structures = StructureLocale.near("#{ville_ou_code_postal}, FRANCE")
                                 .where.not(id: @structures_code_postal)
  end
end
