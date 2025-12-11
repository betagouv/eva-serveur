module Restitution
  module Entreprises
    module Impact
      class ScoreParImpact
        # Si cumul des scores >= 39, alors très fort
        SEUILS_POUR_COUT = {
          39 => :tres_fort,
          26 => :fort,
          13 => :moyen,
          0 => :faible
        }.freeze

        def calcule_score_cout(evenements, pourcentage_risque)
          calcule(evenements, "score_cout", SEUILS_POUR_COUT, pourcentage_risque)
        end

        SEUILS_POUR_STRATEGIE = {
          27 => :tres_fort,
          18 => :fort,
          9 => :moyen,
          0 => :faible
        }.freeze

        def calcule_score_strategie(evenements, pourcentage_risque)
          calcule(evenements, "score_numerique", SEUILS_POUR_STRATEGIE, pourcentage_risque)
        end

        SEUILS_POUR_NUMERIQUE = {
          30 => :tres_fort,
          20 => :fort,
          10 => :moyen,
          0 => :faible
        }.freeze

        def calcule_score_numerique(evenements, pourcentage_risque)
          calcule(evenements, "score_numerique", SEUILS_POUR_NUMERIQUE, pourcentage_risque)
        end

        def calcule(evenements, type_score, seuils, pourcentage_risque)
          evenements_reponse = MetriquesHelper.filtre_evenements_reponses(evenements)
          return if evenements_reponse.blank?

          total = evenements_reponse&.sum { |e| e.donnees[type_score] || 0 }
          total += calcule_malus(pourcentage_risque)

          seuils.each do |seuil, interpretation|
            return interpretation if total >= seuil
          end
        end

        private

        def calcule_malus(pourcentage_risque)
          return 0 if pourcentage_risque <= 10
          return 1 if pourcentage_risque <= 25
          return 2 if pourcentage_risque <= 50
          3 if pourcentage_risque <= 75
        end
      end
    end
  end
end
