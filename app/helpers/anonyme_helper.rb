# frozen_string_literal: true

module AnonymeHelper
  def nom_pour_ressource(ressource, nom: nil)
    prefixe_anonyme = ressource.anonyme? ? inline_svg_tag('anonyme.svg') : ''
    nom = nom.presence || ressource.nom
    prefixe_anonyme + nom
  end
end
