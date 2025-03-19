# frozen_string_literal: true

class SousCompetenceComponent < ViewComponent::Base
  include MarkdownHelper

  def initialize(competence, sous_competence, objet_sous_competence)
    @competence = competence
    @sous_competence = sous_competence
    @objet_sous_competence = objet_sous_competence
  end

  delegate :profil, :nombre_questions_repondues, :nombre_total_questions, :succes,
           :pourcentage_reussite, :nombre_questions_reussies, :nombre_questions_echecs,
           :nombre_questions_non_passees, to: :@objet_sous_competence

  def litteratie?
    @competence == :litteratie
  end

  def numeratie?
    @competence == :numeratie
  end

  def badge_status
    return :non_evalue if nombre_questions_repondues.zero?

    succes ? :acquis : :non_acquis
  end

  def titre_traduction
    "#{traduction_path}.#{@competence}.#{@sous_competence}.titre"
  end

  def description_traduction(profil)
    "#{traduction_path}.#{@competence}.#{@sous_competence}.description.#{profil}"
  end

  def resultat
    nombre_questions_repondues.zero? ? '' : "Score #{pourcentage_reussite}% "
  end

  private

  def traduction_path
    'admin.evaluations.positionnement.sous_competences'
  end
end
