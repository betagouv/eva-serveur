# frozen_string_literal: true

class FabriqueEvenement
  attr_reader :parametres

  def initialize(parametres)
    @parametres = parametres
  end

  def call
    partie = recupere_partie
    return if partie.blank?

    param = EvenementParams.from(parametres).merge(partie: partie)
    Evenement.new(param).tap do |evenement|
      next unless evenement.save

      PersisteMetriquesPartieJob.perform_later(partie) if evenement.fin_situation?
    end
  end

  private

  def recupere_partie
    situation = Situation.find_by(nom_technique: parametres[:situation])
    partie = find_or_create_partie_atomic(parametres[:session_id],
                                          situation,
                                          parametres[:evaluation_id])
    if partie.situation != situation || partie.evaluation_id != parametres[:evaluation_id]
      return nil
    end

    partie.persisted? ? partie : nil
  end

  def find_or_create_partie_atomic(session_id, situation, evaluation_id)
    Partie.find_or_create_by(session_id: session_id) do |p|
      p.situation = situation
      p.evaluation_id = evaluation_id
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
