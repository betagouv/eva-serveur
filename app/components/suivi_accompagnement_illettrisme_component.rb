# Tous les blocs (question, qualification, réponses) sont rendus ; le JS partagé
# avec le tableau de bord (mise_en_action.js.erb) n'en montre qu'un selon l'état.
class SuiviAccompagnementIllettrismeComponent < ViewComponent::Base
  # Trois écrans affichent la même carte (docs/mise_en_action_ecrans.md) :
  # - :evaluation, la fiche évaluation : en-tête large, sans lien ;
  # - :tableau_de_bord, qui propose une personne à la fois et enchaîne sur la suivante ;
  # - :fiche_beneficiaire, qui renvoie vers l'évaluation affichée.
  CONTEXTES = %i[evaluation tableau_de_bord fiche_beneficiaire].freeze

  def initialize(evaluation:, contexte: :evaluation)
    @evaluation = evaluation
    @contexte = contexte
  end

  def reponses
    return [ true, false ] unless MiseEnAction.pas_encore_actif?

    [ true, MiseEnAction::REPONSE_PAS_ENCORE, false ]
  end

  def tableau_de_bord?
    @contexte == :tableau_de_bord
  end

  def lien_evaluation?
    @contexte != :evaluation
  end

  def compact?
    tableau_de_bord?
  end

  def classes
    [ "carte__conteneur", "suivi-accompagnement-illettrisme",
      ("suivi-accompagnement-illettrisme--compacte" unless @contexte == :evaluation),
      ("suivi-accompagnement-illettrisme--tableau-de-bord" if tableau_de_bord?) ]
      .compact.join(" ")
  end
end
