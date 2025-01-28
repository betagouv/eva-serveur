# frozen_string_literal: true

class SousCompetenceComponent < ViewComponent::Base
  def initialize(competence, sous_competence, objet_sous_competence)
    @competence = competence
    @sous_competence = sous_competence
    @objet_sous_competence = objet_sous_competence
  end

  def litteratie?
    @competence == :litteratie
  end

  def avec_succes?
    @objet_sous_competence.respond_to?(:succes)
  end

  def badge_type
    @objet_sous_competence.succes ? :acquis : :non_acquis
  end

  def titre_traduction
    "#{traduction_path}.#{@competence}.#{@sous_competence}.titre"
  end

  def description_traduction(profil)
    "#{traduction_path}.#{@competence}.#{@sous_competence}.description.#{profil}"
  end

  def profil
    if @objet_sous_competence.is_a?(Hash)
      @objet_sous_competence[:profil]
    else
      @objet_sous_competence.profil
    end
  end

  private

  def traduction_path
    'admin.evaluations.positionnement.sous_competences'
  end
end
