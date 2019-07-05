# frozen_string_literal: true

class EvenementParams
  def self.from(params)
    params.permit(
      :date,
      :nom,
      :session_id,
      :utilisateur,
      donnees: {}
    ).merge(recupere_situation(params))
  end

  def self.recupere_situation(params)
    nom_technique = params['situation']
    situation = Situation.find_by(nom_technique: nom_technique)
    { situation: situation }
  end
end
