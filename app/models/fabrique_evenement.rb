# frozen_string_literal: true

class FabriqueEvenement
  attr_reader :parametres

  def initialize(parametres)
    @parametres = parametres
  end

  def call
    partie = recupere_partie
    evenement = Evenement.new EvenementParams.from(parametres).merge(partie: partie)
    evenement.save
    PersisteMetriquesPartieJob.perform_later(partie) if evenement.fin_situation?
    evenement
  end

  private

  def recupere_partie
    situation = Situation.find_by(nom_technique: parametres[:situation])
    partie = begin
      Partie.find_or_create_by(session_id: parametres[:session_id],
                               situation: situation,
                               evaluation_id: parametres[:evaluation_id])
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    partie.persisted? ? partie : nil
  end
end
