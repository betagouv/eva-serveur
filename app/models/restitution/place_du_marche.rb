# frozen_string_literal: true

require_relative '../../decorators/evenement_place_du_marche'

module Restitution
  class PlaceDuMarche < Base
    SCORES_NIVEAUX = {
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

    SCORES_CLEA = {
      '2.1' => { pourcentage_reussite: 0, seuil: 75 },
      '2.2' => { pourcentage_reussite: 0, seuil: 50 },
      '2.3' => { pourcentage_reussite: 0, seuil: 75 },
      '2.4' => { pourcentage_reussite: 0, seuil: 100 },
      '2.5' => { pourcentage_reussite: 0, seuil: 66 }
    }.freeze

    SEUIL_MINIMUM = 70

    def initialize(campagne, evenements)
      @campagne = campagne
      @evenements = evenements
      @evenements_place_du_marche = evenements.map { |e| EvenementPlaceDuMarche.new e }
      calcule_pourcentage_reussite_competence_clea
      super
    end

    def score_pour(niveau)
      SCORES_NIVEAUX[niveau]['score'].calcule(@evenements_place_du_marche, niveau,
                                              avec_rattrapage: true)
    end

    def calcule_pourcentage_reussite_competence_clea
      SCORES_CLEA.each_key do |code|
        next unless evenements_groupes_cleas[code]

        SCORES_CLEA[code][:pourcentage_reussite] =
          Evacob::ScoreMetacompetence.new
                                     .calcule_pourcentage_reussite(
                                       evenements_groupes_cleas[code].values.flatten
                                     )
      end
    end

    def pourcentage_de_reussite_pour(niveau)
      SCORES_NIVEAUX[niveau]['succes'].calcule_pourcentage_reussite(@evenements_place_du_marche,
                                                                    niveau)
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

      Competence::ProfilEvacob.new(self, 'profil_numeratie', niveau_numeratie).profil_numeratie
    end

    def a_passe_des_questions_de_rattrapage?
      evenements_rattrapage = MetriquesHelper
                              .filtre_evenements_reponses(@evenements_place_du_marche) do |e|
        e.donnees['question'].start_with?('N3R')
      end
      evenements_rattrapage.present?
    end

    # rubocop:disable Naming/VariableNumber
    def competences_numeratie
      @competences_numeratie ||= {
        '2_1': { profil: succes?('2.1'), pourcentage: SCORES_CLEA['2.1'][:pourcentage_reussite] },
        '2_2': { profil: succes?('2.2'), pourcentage: SCORES_CLEA['2.2'][:pourcentage_reussite] },
        '2_3': { profil: succes?('2.3'), pourcentage: SCORES_CLEA['2.3'][:pourcentage_reussite] },
        '2_4': { profil: succes?('2.4'), pourcentage: SCORES_CLEA['2.4'][:pourcentage_reussite] },
        '2_5': { profil: succes?('2.5'), pourcentage: SCORES_CLEA['2.5'][:pourcentage_reussite] }
      }
    end
    # rubocop:enable Naming/VariableNumber

    private

    def succes?(code_clea)
      SCORES_CLEA[code_clea][:pourcentage_reussite] >= SCORES_CLEA[code_clea][:seuil]
    end

    def evenements_groupes_cleas
      @evenements_groupes_cleas ||= begin
        situation = Situation.find_by(nom_technique: 'place_du_marche')
        questionnaire = @campagne.questionnaire_pour(situation)
        @evenements.regroupe_par_codes_clea(questionnaire, %w[N1R N2R N3R])
      end
    end
  end
end
