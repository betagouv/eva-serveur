# frozen_string_literal: true

require_relative '../../decorators/evenement_place_du_marche'

module Restitution
  class PlaceDuMarche < Base
    SCORES = {
      N1: {
        'type' => :nombre,
        'score' => Evacob::ScoreModule.new,
        'succes' => Evacob::ScoreModule.new
      },
      N2: {
        'type' => :nombre,
        'score' => Evacob::ScoreModule.new,
        'succes' => Evacob::ScoreModule.new
      },
      N3: {
        'type' => :nombre,
        'score' => Evacob::ScoreModule.new,
        'succes' => Evacob::ScoreModule.new
      }
    }.freeze
    SEUIL_MINIMUM = 70

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementPlaceDuMarche.new e }
      super
    end

    def score_pour(niveau, avec_rattrapage: true)
      SCORES[niveau]['score'].calcule(evenements, niveau, avec_rattrapage: avec_rattrapage)
    end

    def pourcentage_de_reussite_pour(niveau)
      SCORES[niveau]['succes'].calcule_pourcentage_reussite(evenements, niveau)
    end

    def synthese
      { numeratie_niveau1: score_pour(:N1),
        numeratie_niveau2: score_pour(:N2),
        numeratie_niveau3: score_pour(:N3),
        profil_numeratie: profil_numeratie }
    end

    def niveau_numeratie # rubocop:disable Metrics/CyclomaticComplexity
      niveau = 0
      return niveau if pourcentage_de_reussite_pour(:N1).blank?

      n2 = pourcentage_de_reussite_pour(:N2)
      n3 = pourcentage_de_reussite_pour(:N3)

      niveau = 1
      niveau = 2 if n2
      niveau = 3 if n3
      niveau = 4 if n3 && n3 > SEUIL_MINIMUM
      niveau = 5 if niveau == 4 && !a_passe_des_questions_de_rattrapage?

      niveau
    end

    def profil_numeratie
      return ::Competence::NIVEAU_INDETERMINE if niveau_numeratie.zero?

      Competence::ProfilEvacob.new(self, 'profil_numeratie',
                                   niveau_numeratie).profil_numeratie
    end

    def a_passe_des_questions_de_rattrapage?
      evenements_rattrapage = MetriquesHelper.filtre_evenements_reponses(evenements) do |e|
        e.donnees['question'].start_with?('N3R')
      end
      evenements_rattrapage.present?
    end
  end
end
