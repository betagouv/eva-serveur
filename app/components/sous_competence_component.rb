# frozen_string_literal: true

class SousCompetenceComponent < ViewComponent::Base
  include MarkdownHelper

  def initialize(competence, sous_competence, objet_sous_competence)
    @competence = competence
    @sous_competence = sous_competence
    @objet_sous_competence = objet_sous_competence
  end

  def litteratie?
    @competence == :litteratie
  end

  def numeratie?
    @competence == :numeratie
  end

  def badge_type
    succes ? :acquis : :non_acquis
  end

  def titre_traduction
    "#{traduction_path}.#{@competence}.#{@sous_competence}.titre"
  end

  def description_traduction(profil)
    "#{traduction_path}.#{@competence}.#{@sous_competence}.description.#{profil}"
  end

  def tests_proposes_traduction
    "#{traduction_path}.tests_proposes"
  end

  def profil
    @objet_sous_competence.profil
  end

  def nombre_questions_repondues
    @objet_sous_competence.nombre_questions_repondues
  end

  def nombre_total_questions
    @objet_sous_competence.nombre_total_questions
  end

  def succes
    @objet_sous_competence.succes
  end

  def pourcentage_reussite
    @objet_sous_competence.pourcentage_reussite
  end

  private

  def traduction_path
    'admin.evaluations.positionnement.sous_competences'
  end
end
