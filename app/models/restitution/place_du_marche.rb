# frozen_string_literal: true

require_relative '../../decorators/evenement_place_du_marche'

module Restitution
  class PlaceDuMarche < Base
    SCORES = {
      'score_N1' => {
        'type' => :nombre,
        'parametre' => :N1,
        'score' => Evacob::ScoreModule.new,
        'succes' => Evacob::ScoreModule.new
      },
      'score_N2' => {
        'type' => :nombre,
        'parametre' => :N2,
        'score' => Evacob::ScoreModule.new,
        'succes' => Evacob::ScoreModule.new
      },
      'score_N3' => {
        'type' => :nombre,
        'parametre' => :N3,
        'score' => Evacob::ScoreModule.new,
        'succes' => Evacob::ScoreModule.new
      }
    }.freeze
    SEUIL_MINIMUM = 70

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementPlaceDuMarche.new e }
      super
    end

    def score_pour(niveau)
      SCORES["score_#{niveau}"]['score'].calcule(evenements, niveau, avec_rattrapage: true)
    end

    def pourcentage_de_reussite_pour(niveau)
      SCORES["score_#{niveau}"]['succes'].calcule_pourcentage_reussite(
        evenements,
        SCORES["score_#{niveau}"]['parametre']
      )
    end

    def synthese
      { numeratie_niveau1: score_pour(:N1),
        numeratie_niveau2: score_pour(:N2),
        numeratie_niveau3: score_pour(:N3),
        profil_numeratie: profil_numeratie }
    end

    def niveau_numeratie
      niveau = 0
      n1 = pourcentage_de_reussite_pour(:N1)
      return niveau if n1.blank?

      n2 = pourcentage_de_reussite_pour(:N2)
      n3 = pourcentage_de_reussite_pour(:N3)

      niveau = 1
      niveau = 2 if n1 > SEUIL_MINIMUM
      niveau = 3 if n2 && n2 > SEUIL_MINIMUM
      niveau = 4 if n3 && n3 > SEUIL_MINIMUM

      niveau
    end

    def profil_numeratie
      return ::Competence::NIVEAU_INDETERMINE if niveau_numeratie.zero?

      Competence::ProfilEvacob.new(self, 'profil_numeratie',
                                   niveau_numeratie).profil_numeratie
    end
  end
end
