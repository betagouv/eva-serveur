module Restitution
  module Entreprises
    module Impact
      class InterpretationScoring
        # Si cumul des scores >= 15, alors très fort
        PERFORMANCE_COLLECTIVE_PAR_SEUIL = {
          15 => :tres_fort,
          10 => :fort,
          5 => :moyen,
          0 => :faible
        }.freeze

        def calcule_performence_collective(evenements)
          calcule(evenements, PERFORMANCE_COLLECTIVE_PAR_SEUIL)
        end

        AGILITE_ORGANISATIONNELLE_PAR_SEUIL = {
          18 => :tres_fort,
          12 => :fort,
          6 => :moyen,
          0 => :faible
        }.freeze

        def calcule_agilite_organisationnelle(evenements)
          calcule(evenements, AGILITE_ORGANISATIONNELLE_PAR_SEUIL)
        end

        SECURITE_QUALITE_PAR_SEUIL = {
          31 => :tres_fort,
          21 => :fort,
          10 => :moyen,
          0 => :faible
        }.freeze
        def calcule_securite_qualite(evenements)
          calcule(evenements, SECURITE_QUALITE_PAR_SEUIL)
        end

        MOBILITE_PROFESSIONNELLE_PAR_SEUIL = {
          39 => :tres_fort,
          26 => :fort,
          13 => :moyen,
          0 => :faible
        }.freeze
        def calcule_mobilite_professionnelle(evenements)
          calcule(evenements, MOBILITE_PROFESSIONNELLE_PAR_SEUIL)
        end

        def calcule(evenements, seuils)
          evenements_reponse = MetriquesHelper.filtre_evenements_reponses(evenements)

          return if evenements_reponse.blank?

          total = evenements_reponse&.sum { |e| score_impact(e) }

          seuils.each do |seuil, interpretation|
            return interpretation if total >= seuil
          end
        end

        private

         # additionne score_cout, score_numerique et score_strategies
         def score_impact(evenement)
          score_cout = evenement.donnees["score_cout"] || 0
          score_numerique = evenement.donnees["score_numerique"] || 0
          score_strategies = evenement.donnees["score_strategies"] || 0

          score_cout + score_numerique + score_strategies
        end
      end
    end
  end
end
