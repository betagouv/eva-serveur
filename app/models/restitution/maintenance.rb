# frozen_string_literal: true

require_relative '../../decorators/evenement_maintenance'

module Restitution
  class Maintenance < AvecEntrainement
    METRIQUES = {
      'temps_total' => Base::TempsTotal.new,
      'temps_entrainement' => AvecEntrainement::TempsEntrainement.new,
      'nombre_bonnes_reponses_francais' => Maintenance::NombreBonnesReponsesMotFrancais.new,
      'nombre_bonnes_reponses_non_mot' => Maintenance::NombreBonnesReponsesNonMot.new,
      'nombre_non_reponses' => Maintenance::NombreNonReponses.new,
      'temps_moyen_mots_francais' =>
                       Metriques::Moyenne.new(Maintenance::TempsMotsFrancais.new),
      'temps_moyen_non_mots' =>
                       Metriques::Moyenne.new(Maintenance::TempsNonMots.new)
    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementMaintenance.new e }
      super(campagne, evenements)
    end

    METRIQUES.keys.each do |metrique|
      define_method metrique do
        METRIQUES[metrique]
          .calcule(evenements_situation, evenements_entrainement)
      end
    end

    def persiste
      metriques = METRIQUES.keys.each_with_object({}) do |nom_metrique, memo|
        memo[nom_metrique] = public_send(nom_metrique)
      end
      partie.update(metriques: metriques)
    end

    def temps_moyen_normalise(nom_moyenne, metrique_des_temps)
      moyenne_glissante = partie.moyenne_metrique(nom_moyenne)
      ecart_type_glissant = partie.ecart_type_metrique(nom_moyenne)

      metrique_des_temps_normalises = Metriques::TempsNormalises.new(metrique_des_temps,
                                                                     moyenne_glissante,
                                                                     ecart_type_glissant)
      Metriques::Moyenne
        .new(metrique_des_temps_normalises)
        .calcule(@evenements_situation, @evenements_entrainement)
    end

    def sous_score(nombre, nom_moyenne, metrique_des_temps)
      return 0 if nombre.zero?

      temps_moyen_normalise = temps_moyen_normalise(nom_moyenne, metrique_des_temps)

      nombre / temps_moyen_normalise
    end

    def score
      sous_score(nombre_bonnes_reponses_francais,
                 :temps_moyen_mots_francais,
                 Maintenance::TempsMotsFrancais.new) *
        sous_score(nombre_bonnes_reponses_non_mot,
                   :temps_moyen_non_mots,
                   Maintenance::TempsNonMots.new)
    end
  end
end
