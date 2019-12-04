# frozen_string_literal: true

class CreeEvenementAction
  FIN_SITUATION = 'finSituation'

  attr_reader :partie, :evenement

  def initialize(partie, evenement)
    @partie = partie
    @evenement = evenement
  end

  def call
    evenement.save.tap do |persiste|
      next unless persiste

      partie.persiste_restitution if evenement.nom == FIN_SITUATION
    end
  end
end
