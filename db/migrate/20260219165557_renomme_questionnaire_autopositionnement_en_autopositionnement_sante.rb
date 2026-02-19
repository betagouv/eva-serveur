class RenommeQuestionnaireAutopositionnementEnAutopositionnementSante < ActiveRecord::Migration[7.2]
  def up
    Questionnaire.where(nom_technique: "sociodemographique_autopositionnement")
                 .update_all(
                   nom_technique: "sociodemographique_autopositionnement_sante",
                   libelle: "Sociodémographique, autopositionnement et santé"
                 )
  end

  def down
    Questionnaire.where(nom_technique: "sociodemographique_autopositionnement_sante")
                 .update_all(
                   nom_technique: "sociodemographique_autopositionnement",
                   libelle: "Sociodémographique et autopositionnement"
                 )
  end
end
