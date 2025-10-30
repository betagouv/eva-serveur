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
        PERFORMANCE_COLLECTIVE_QUESTIONS = %w[Q2PC01 Q2PC02 Q2PC03]

        def calcule_performance_collective(evenements)
          calcule(evenements, PERFORMANCE_COLLECTIVE_QUESTIONS, PERFORMANCE_COLLECTIVE_PAR_SEUIL)
        end

        AGILITE_ORGANISATIONNELLE_PAR_SEUIL = {
          18 => :tres_fort,
          12 => :fort,
          6 => :moyen,
          0 => :faible
        }.freeze
        AGILITE_ORGANISATIONNELLE_QUESTIONS = %w[Q2AO01 Q2AO02 Q2AO03 Q2AO04]

        def calcule_agilite_organisationnelle(evenements)
          calcule(evenements, AGILITE_ORGANISATIONNELLE_QUESTIONS,
AGILITE_ORGANISATIONNELLE_PAR_SEUIL)
        end

        SECURITE_QUALITE_PAR_SEUIL = {
          31 => :tres_fort,
          21 => :fort,
          10 => :moyen,
          0 => :faible
        }.freeze
        SECURITE_QUALITE_QUESTIONS = %w[Q2SQ01 Q2SQ02 Q2SQ03 Q2SQ04 Q2SQ05 Q2SQ06 Q2SQ07]

        def calcule_securite_qualite(evenements)
          calcule(evenements, SECURITE_QUALITE_QUESTIONS, SECURITE_QUALITE_PAR_SEUIL)
        end

        MOBILITE_PROFESSIONNELLE_PAR_SEUIL = {
          39 => :tres_fort,
          26 => :fort,
          13 => :moyen,
          0 => :faible
        }.freeze
        MOBILITE_PROFESSIONNELLE_QUESTIONS = %w[Q2MP01 Q2MP02 Q2MP03 Q2MP04 Q2MP05 Q2MP06 Q2MP07
Q2MP08]
        def calcule_mobilite_professionnelle(evenements)
          calcule(evenements, MOBILITE_PROFESSIONNELLE_QUESTIONS,
MOBILITE_PROFESSIONNELLE_PAR_SEUIL)
        end

        def calcule(evenements, questions, seuils)
          evenements_reponse = MetriquesHelper.filtre_evenements_reponses(evenements)
          return if evenements_reponse.blank?

          evenements_reponse = evenements_reponse.select { |e|
 questions.include?(e.donnees["question"]) }
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
