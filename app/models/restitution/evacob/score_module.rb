# frozen_string_literal: true

module Restitution
  module Evacob
    class ScoreModule
      NUMERATIE_METRIQUES = {
        'N1Pse' => nil,
        'N1Prn' => 'N1Rrn',
        'N1Pde' => 'N1Rde',
        'N1Pes' => 'N1Res',
        'N1Pon' => 'N1Ron',
        'N1Poa' => 'N1Roa',
        'N1Pos' => 'N1Ros',
        'N1Pvn' => nil
      }.freeze

      def calcule(evenements, nom_module, avec_rattrapage: false)
        evenements_reponse = MetriquesHelper.filtre_evenements_reponses(evenements) do |e|
          e.module?(nom_module)
        end

        return if evenements_reponse.empty?

        e_filtres = avec_rattrapage ? filtre_rattrapage(evenements_reponse) : evenements_reponse
        e_filtres.sum(&:score_reponse)
      end

      private

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
