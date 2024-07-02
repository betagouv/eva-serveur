# frozen_string_literal: true

require_relative '../../decorators/evenement_place_du_marche'

module Restitution
  class PlaceDuMarche < Base
    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementPlaceDuMarche.new e }
      super
    end

    def score_niveau1
      Evacob::ScoreModule.new.calcule(evenements, :N1P)
    end

    def score_niveau2
      Evacob::ScoreModule.new.calcule(evenements, :NumeratieN2)
    end

    def score_niveau3
      Evacob::ScoreModule.new.calcule(evenements, :NumeratieN3)
    end

    def synthese
      { numeratie_niveau1: score_niveau1,
        numeratie_niveau2: score_niveau2,
        numeratie_niveau3: score_niveau3 }
    end
  end
end
