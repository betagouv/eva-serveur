# frozen_string_literal: true

module EvaluationHelper
  def niveau_bas?(profil)
    ::Competence::PROFILS_BAS.include?(profil)
  end

  def presence_pastille?
    liste_filtree_illettrisme_potentiel = params[:scope] == 'illettrisme_potentiel'
    liste_filtree_illettrisme_potentiel ? false : true
  end
end
