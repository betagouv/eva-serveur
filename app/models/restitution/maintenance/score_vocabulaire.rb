# frozen_string_literal: true

module Restitution
  class Maintenance
    class ScoreVocabulaire < Restitution::Metriques::Base
      def initialize(metrique_nbr_mot_francais = Maintenance::NombreBonnesReponsesMotFrancais.new,
                     metrique_nbr_non_mot = Maintenance::NombreBonnesReponsesNonMot.new)
        @metrique_nbr_mot_francais = metrique_nbr_mot_francais
        @metrique_nbr_non_mot = metrique_nbr_non_mot
      end

      def calcule(evenements_situation, _)
        @evenements_situation = evenements_situation

        sous_score(@metrique_nbr_mot_francais,
                   :temps_moyen_mots_francais,
                   Maintenance::TempsMotsFrancais.new) *
          sous_score(@metrique_nbr_non_mot,
                     :temps_moyen_non_mots,
                     Maintenance::TempsNonMots.new)
      end

      def partie
        @evenements_situation.first.partie
      end

      def temps_moyen_normalise(nom_moyenne, metrique_des_temps)
        moyenne_glissante = partie.moyenne_metrique(nom_moyenne)
        ecart_type_glissant = partie.ecart_type_metrique(nom_moyenne)

        metrique_des_temps_normalises = Metriques::TempsNormalises.new(metrique_des_temps,
                                                                       moyenne_glissante,
                                                                       ecart_type_glissant)
        Metriques::Moyenne
          .new(metrique_des_temps_normalises)
          .calcule(@evenements_situation, nil)
      end

      private

      def sous_score(metrique_nombre, nom_moyenne, metrique_des_temps)
        nombre = metrique_nombre.calcule(@evenements_situation, nil)
        return 0 if nombre.zero?

        temps_moyen_normalise = temps_moyen_normalise(nom_moyenne, metrique_des_temps)
        return 0 unless temps_moyen_normalise.present?

        nombre / temps_moyen_normalise
      end
    end
  end
end
