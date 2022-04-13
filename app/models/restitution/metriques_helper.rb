# frozen_string_literal: true

module Restitution
  class MetriquesHelper
    EVENEMENT = {
      DEMARRAGE: 'demarrage',
      ACTIVATION_AIDE1: 'activationAide',
      REPONSE: 'reponse'
    }.freeze

    class << self
      def premier_evenement_du_nom(evenements, nom_evenement)
        evenements.find { |e| e.nom == EVENEMENT[nom_evenement] }
      end

      def temps_entre_couples(evenements)
        les_temps = []
        evenements.each_slice(2) do |e1, e2|
          next if e2.blank?

          les_temps << (e2.date - e1.date)
        end
        les_temps
      end

      def temps_chaque_question(evenements)
        les_temps = []
        evenements.each_slice(2) do |e1, e2|
          next if e2.blank?

          les_temps << {
            question: e1.question_nom_technique,
            succes: e2.bonne_reponse?,
            temps: (e2.date - e1.date)
          }
        end
        les_temps
      end

      def activation_aide1(evenements)
        premier_evenement_du_nom(evenements, :ACTIVATION_AIDE1)
      end

      def temps_questions(evenements, &filtre_evenements)
        temps_chaque_question(
          apparitions_et_reponses(evenements, :present?, &filtre_evenements)
        )
      end

      def temps_action(evenements, filtre_reponse, &filtre_evenements)
        temps_entre_couples(
          apparitions_et_reponses(evenements, filtre_reponse, &filtre_evenements)
        )
      end

      private

      def apparitions_et_reponses(evenements, filtre_reponse, &filtre_evenements)
        evenements_retenus = []
        evenements.select(&filtre_evenements).each_slice(2) do |apparition, reponse|
          next unless reponse&.send(filtre_reponse)

          evenements_retenus << apparition << reponse
        end
        evenements_retenus
      end
    end
  end
end
