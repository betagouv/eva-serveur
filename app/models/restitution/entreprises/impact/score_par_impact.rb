module Restitution
  module Entreprises
    module Impact
      class ScoreParImpact
        SEUILS = {
          score_cout: {
            39 => :tres_fort,
            26 => :fort,
            13 => :moyen,
            0 => :faible
          },
          score_strategies: {
            27 => :tres_fort,
            18 => :fort,
            9 => :moyen,
            0 => :faible
          },
          score_numerique: {
            30 => :tres_fort,
            20 => :fort,
            10 => :moyen,
            0 => :faible
          }
        }.freeze

        def calcule_score_cout(evenements, pourcentage_risque)
          calcule(evenements, :score_cout, pourcentage_risque)
        end

        def calcule_score_strategie(evenements, pourcentage_risque)
          calcule(evenements, :score_strategies, pourcentage_risque)
        end

        def calcule_score_numerique(evenements, pourcentage_risque)
          calcule(evenements, :score_numerique, pourcentage_risque)
        end

        def calcule(evenements, type_score, pourcentage_risque)
          evenements_reponse = MetriquesHelper.filtre_evenements_reponses(evenements)
          return if evenements_reponse.blank?

          total = evenements_reponse.sum { |e| e.donnees[type_score.to_s] || 0 }
          total += calcule_malus(pourcentage_risque)

          SEUILS[type_score].each do |seuil, interpretation|
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
