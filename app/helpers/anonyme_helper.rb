# frozen_string_literal: true

module AnonymeHelper
  def nom_pour_evaluation(evaluation)
    nom_pour_ressource(evaluation)
  end

  def nom_pour_beneficiaire(beneficiaire)
    nom_pour_ressource(beneficiaire)
  end

  def nom_pour_ressource(ressource)
    prefixe_anonyme = ressource.anonyme? ? inline_svg_tag('anonyme.svg') : ''
    prefixe_anonyme + ressource.nom
  end
end
