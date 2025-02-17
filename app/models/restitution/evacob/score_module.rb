# frozen_string_literal: true

module Restitution
  module Evacob
    class ScoreModule
      # Le tableau suivant correspond au tableau numeratieMetriques de
      # src/situations/place_du_marche/modeles/store.js dans eva
      NUMERATIE_METRIQUES = {
        'N1Pse' => nil,
        'N1Prn' => 'N1Rrn',
        'N1Pde' => 'N1Rde',
        'N1Pes' => 'N1Res',
        'N1Pon' => 'N1Ron',
        'N1Poa' => 'N1Roa',
        'N1Pos' => 'N1Ros',
        'N1Pvn' => nil,
        'N2Plp' => 'N2Rlp',
        'N2Ppe' => 'N2Rpe',
        'N2Psu' => 'N2Rsu',
        'N2Pom' => 'N2Rom',
        'N2Pon' => 'N2Ron',
        'N2Pod' => 'N2Rod',
        'N2Put' => 'N2Rut',
        'N2Prh' => 'N2Rrh',
        'N2Ptg' => 'N2Rtg',
        'N2Ppl' => 'N2Rpl',
        'N3Ppl' => 'N3Rpl',
        'N3Put' => 'N3Rut',
        'N3Pum' => nil,
        'N3Pim' => nil,
        'N3Ppo' => 'N3Rpo',
        'N3Ppr' => 'N3Rpr',
        'N3Pps' => 'N3Rps',
        'N3Pvo' => 'N3Rvo',
        'N3Prp' => 'N3Rrp'
      }.freeze

      SCORE_MAX_PAR_NIVEAU = {
        N1: 16,
        N2: 20,
        N3: 18
      }.freeze

      def calcule(evenements, nom_module, avec_rattrapage: false)
        evenements_filtres = recupere_evenements_reponses_filtres(evenements, nom_module,
                                                                  avec_rattrapage)

        evenements_filtres&.sum(&:score_reponse)
      end

      def calcule_pourcentage_reussite(evenements, nom_module)
        evenements = recupere_evenements_reponses_filtres(evenements, nom_module,
                                                          a_une_question_rattrapage?(evenements))

        return if evenements.blank?

        score_max = SCORE_MAX_PAR_NIVEAU[nom_module]
        score = evenements&.sum(&:score_reponse)

        Pourcentage.new(valeur: score, valeur_max: score_max).calcul
      end

      def a_une_question_rattrapage?(evenements)
        evenements.any? do |e|
          NUMERATIE_METRIQUES.values.compact.any? do |metrique|
            next if e.donnees['score'].blank?

            e.donnees['question'].start_with?(metrique)
          end
        end
      end

      private

      def recupere_evenements_reponses_filtres(evenements, nom_module, avec_rattrapage)
        evenements_reponse = MetriquesHelper.filtre_evenements_reponses(evenements) do |e|
          e.module?(nom_module)
        end

        return if evenements_reponse.empty?

        avec_rattrapage ? filtre_rattrapage(evenements_reponse) : evenements_reponse
      end

      def filtre_rattrapage(evenements_reponse)
        scores_totaux = calcule_scores_totaux(evenements_reponse)
        scores_max = recupere_score_max(scores_totaux)

        scores_max.flat_map do |metrique|
          evenements_reponse.select do |e|
            e.donnees['question'].start_with?(metrique)
          end
        end
      end

      def calcule_scores_totaux(evenements_reponse)
        scores_totaux = Hash.new(0)

        NUMERATIE_METRIQUES.each do |question_initiale, rattrapage|
          scores_totaux[question_initiale] =
            calcule_score_total_par_metrique(evenements_reponse, question_initiale)
          scores_totaux[rattrapage] =
            calcule_score_total_par_metrique(evenements_reponse, rattrapage)
        end

        scores_totaux
      end

      def calcule_score_total_par_metrique(evenements_reponse, metrique)
        return 0 unless metrique

        evenements_reponse
          .select { |e| e.donnees['question'].start_with?(metrique) }
          .sum(&:score_reponse)
      end

      def recupere_score_max(score_totaux)
        NUMERATIE_METRIQUES.keys.map do |question|
          [question, NUMERATIE_METRIQUES[question]].max_by { |metrique| score_totaux[metrique] }
        end
      end
    end
  end
end
