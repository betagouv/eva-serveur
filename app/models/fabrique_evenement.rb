# frozen_string_literal: true

class FabriqueEvenement
  attr_reader :parametres

  def initialize(parametres)
    @parametres = parametres
  end

  def call
    ActiveRecord::Base.transaction do
      partie = recupere_partie
      @evenement = Evenement.new EvenementParams.from(parametres).merge(partie: partie)
      resultat = CreeEvenementAction.new(partie, @evenement).call
      raise ActiveRecord::Rollback unless resultat
    end
    @evenement
  end

  private

  def recupere_partie
    situation = Situation.find_by(nom_technique: parametres[:situation])
    partie = Partie.where(session_id: parametres[:session_id],
                          situation: situation,
                          evaluation_id: parametres[:evaluation_id])
                   .first_or_create
    partie.persisted? ? partie : nil
  end
end
