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

      restitution = FabriqueRestitution.instancie partie.id
      restitution.persiste
      restitution_globale = FabriqueRestitution.restitution_globale partie.evaluation
      restitution_globale.persiste
    end
  end
end
