# frozen_string_literal: true

require_relative '../../decorators/evenement_place_du_marche'

module Restitution
  class PlaceDuMarche < Base # rubocop:disable Metrics/ClassLength
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
      '2.1' => { pourcentage_reussite: 0, seuil: 75, nombre_questions_repondues: 0,
                 nombre_questions_reussies: 0,
                 nombre_questions_echecs: 0, nombre_questions_non_passees: 0 },
      '2.2' => { pourcentage_reussite: 0, seuil: 50, nombre_questions_repondues: 0,
                 nombre_questions_reussies: 0,
                 nombre_questions_echecs: 0, nombre_questions_non_passees: 0 },
      '2.3' => { pourcentage_reussite: 0, seuil: 75, nombre_questions_repondues: 0,
                 nombre_questions_reussies: 0,
                 nombre_questions_echecs: 0, nombre_questions_non_passees: 0 },
      '2.4' => { pourcentage_reussite: 0, seuil: 100, nombre_questions_repondues: 0,
                 nombre_questions_reussies: 0,
                 nombre_questions_echecs: 0, nombre_questions_non_passees: 0 },
      '2.5' => { pourcentage_reussite: 0, seuil: 66, nombre_questions_repondues: 0,
                 nombre_questions_reussies: 0,
                 nombre_questions_echecs: 0, nombre_questions_non_passees: 0 }
    }.freeze

    SEUIL_MINIMUM = 70

    def initialize(campagne, evenements) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      @campagne = campagne
      @evenements = evenements
      evenements_reponses = evenements.select { |evenement| evenement.nom == 'reponse' }
      evenements.first.situation
      @evenements_place_du_marche = evenements.map { |e| EvenementPlaceDuMarche.new e }

      questions_situation = campagne.situations_configurations
                                    .map(&:questionnaire_utile)
                                    .compact
                                    .flatten
                                    .map(&:questions)
                                    .flatten
                                    .reject do |question|
                                      question.type == QuestionSousConsigne::QUESTION_TYPE
                                    end

      noms_techniques = evenements_reponses.map(&:question_nom_technique)
      @questions_repondues = Question.where(nom_technique: noms_techniques)

      @evenements_questions = questions_situation.map do |question_situation|
        evenement = evenements_reponses.find do |e|
          e.question_nom_technique == question_situation.nom_technique
        end
        EvenementQuestion.new(question: question_situation, evenement: evenement)
      end

      @evenements_questions_a_prendre_en_compte =
        EvenementQuestion.prises_en_compte_pour_calcul_score_clea(@evenements_questions)
      calcule_pourcentage_reussite_competence_clea
      super
    end

    def score_pour(niveau)
      SCORES_NIVEAUX[niveau]['score'].calcule(@evenements_place_du_marche, niveau,
                                              avec_rattrapage: true)
    end

    def calcule_pourcentage_reussite_competence_clea # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      SCORES_CLEA.each_key do |code|
        SCORES_CLEA[code][:criteres] = []
        Metacompetence::CORRESPONDANCES_CODECLEA[code].each_key do |sous_code|
          calcule_pourcentage_reussite_critere_clea(code, sous_code)
        end

        eq_pour_code = evenements_questions_pour_code(code)
        SCORES_CLEA[code][:nombre_total_questions] = eq_pour_code.size
        SCORES_CLEA[code][:nombre_questions_repondues] = eq_pour_code.select(&:a_ete_repondue?).size
        pourcentage = EvenementQuestion.pourcentage_pour_groupe(eq_pour_code)
        SCORES_CLEA[code][:pourcentage_reussite] = pourcentage
      end
    end

    def calcule_pourcentage_reussite_critere_clea(code, sous_code)
      eq_pour_code = evenements_questions_pour_code(sous_code)

      SCORES_CLEA[code][:criteres] << creer_critere_numeratie(eq_pour_code, sous_code)
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
        '2_1': creer_numeratie('2.1'),
        '2_2': creer_numeratie('2.2'),
        '2_3': creer_numeratie('2.3'),
        '2_4': creer_numeratie('2.4'),
        '2_5': creer_numeratie('2.5')
      }
    end
    # rubocop:enable Naming/VariableNumber

    def evaluation_terminee?
      @evenements.any?(&:fin_situation?)
    end

    private

    def evenements_questions_pour_code(code)
      EvenementQuestion.pour_code_clea(@evenements_questions_a_prendre_en_compte, code)
    end

    def creer_numeratie(code)
      Restitution::SousCompetence::Numeratie.new(
        succes: succes?(code),
        pourcentage_reussite: SCORES_CLEA[code][:pourcentage_reussite],
        nombre_questions_repondues: SCORES_CLEA[code][:nombre_questions_repondues],
        nombre_total_questions: SCORES_CLEA[code][:nombre_total_questions],
        nombre_questions_reussies: nombre_questions_reussies_par_sous_domaine(code),
        nombre_questions_echecs: nombre_questions_echecs_par_sous_domaine(code),
        nombre_questions_non_passees: nombre_questions_non_repondues_par_sous_domaine(code),
        criteres: SCORES_CLEA[code][:criteres]
      )
    end

    def succes?(code_clea)
      return false if SCORES_CLEA[code_clea][:pourcentage_reussite].nil?

      SCORES_CLEA[code_clea][:pourcentage_reussite] >= SCORES_CLEA[code_clea][:seuil]
    end

    def evenements_groupes_cleas
      @evenements_groupes_cleas ||= begin
        situation = Situation.find_by(nom_technique: 'place_du_marche')
        @questionnaire = @campagne.questionnaire_pour(situation)
        @evenements.regroupe_par_codes_clea(@questionnaire, %w[N1R N2R N3R])
      end
    end

    def filtre_evenements_reponses(evenements)
      evenements = evenements_par_module(evenements, :N1)
      evenements = evenements_par_module(evenements, :N2)
      evenements_par_module(evenements, :N3)
    end

    def evenements_par_module(evenements, nom_module)
      module_rattrapage = "#{nom_module}R"
      a_fait_un_rattrapage = evenements.any? do |e|
        e['question'].start_with?(module_rattrapage) && e['score'].present?
      end
      return evenements if a_fait_un_rattrapage

      evenements.reject { |e| e['question'].start_with?(module_rattrapage) }
    end

    def questions_non_repondues_par_module(evenements, nom_module)
      module_rattrapage = "#{nom_module}R"
      evenements.select { |e| e['question'].start_with?(module_rattrapage) && e['score'].blank? }
    end

    def calculer_nombres_questions_par_sous_domaine(&block)
      resultats = Hash.new(0)
      SCORES_CLEA.each_key do |code|
        eq_pour_code = evenements_questions_pour_code(code)
        resultats[code] = eq_pour_code.count(&block)
      end
      resultats
    end

    def nombre_questions_reussies_par_sous_domaine(code)
      return 0 if evenements_questions_pour_code(code).empty?

      evenements_questions_pour_code(code).select(&:succes).count
    end

    def nombre_questions_echecs_par_sous_domaine(code)
      return 0 if evenements_questions_pour_code(code).empty?

      evenements_questions_pour_code(code).select { |eq| !eq.succes && eq.a_ete_repondue? }.count
    end

    def nombre_questions_non_repondues_par_sous_domaine(code)
      return 0 if evenements_questions_pour_code(code).empty?

      evenements_questions_pour_code(code).reject(&:a_ete_repondue?).count
    end

    def creer_critere_numeratie(eq_pour_code, sous_code)
      Restitution::Critere::Numeratie.new(
        libelle: Metacompetence::CODECLEA_INTITULES[sous_code],
        code_clea: sous_code,
        nombre_tests_proposes: eq_pour_code.select(&:a_ete_repondue?).size,
        nombre_tests_proposes_max: eq_pour_code.size,
        pourcentage_reussite: EvenementQuestion.pourcentage_pour_groupe(eq_pour_code),
        nombre_questions_reussies: nombre_questions_reussies_par_sous_domaine(sous_code),
        nombre_questions_echecs: nombre_questions_echecs_par_sous_domaine(sous_code),
        nombre_questions_non_passees: nombre_questions_non_repondues_par_sous_domaine(sous_code)
      )
    end
  end
end
