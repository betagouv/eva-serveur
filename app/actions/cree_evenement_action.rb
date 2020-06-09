# frozen_string_literal: true

class CreeEvenementAction
  FIN_SITUATION = 'finSituation'

  attr_reader :partie, :evenement

  def initialize(partie, evenement)
    @partie = partie
    @evenement = evenement
  end

  def call
    evenement.save.tap do |saved|
      next unless saved

      next unless evenement.nom == FIN_SITUATION

      FabriqueRestitution.persiste(partie)
    end
  end
end
