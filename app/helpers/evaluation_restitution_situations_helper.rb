# frozen_string_literal: true

# Méthodes dépendant de `restitution_pour_situation` (helper du contrôleur admin évaluation).
module EvaluationRestitutionSituationsHelper
  def diag_risques_entreprise
    restitution_pour_situation(Situation::DIAG_RISQUES_ENTREPRISE)
  end

  def cafe_de_la_place
    restitution_pour_situation(Situation::CAFE_DE_LA_PLACE)
  end

  def place_du_marche
    restitution_pour_situation(Situation::PLACE_DU_MARCHE)
  end
end
