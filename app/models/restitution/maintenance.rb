# frozen_string_literal: true

module Restitution
  class Maintenance < AvecEntrainement
    METRIQUES = {
      'temps_entrainement' => AvecEntrainement::TempsEntrainement,
      'nombre_bonnes_reponses_francais' => Maintenance::NombreBonnesReponsesMotFrancais,
      'nombre_bonnes_reponses_non_mot' => Maintenance::NombreBonnesReponsesNonMot,
      'nombre_non_reponses' => Maintenance::NombreNonReponses,
      'temps_moyen_mots_francais' => Maintenance::TempsMoyenMotsFrancais,
      'temps_moyen_non_mots' => Maintenance::TempsMoyenNonMots
    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementMaintenanceDecorator.new e }
      super(campagne, evenements)
    end

    METRIQUES.keys.each do |metrique|
      define_method metrique do
        METRIQUES[metrique]
          .new(evenements_situation, evenements_entrainement)
          .calcule
      end
    end

    def persiste
      metriques = METRIQUES.keys.each_with_object({}) do |nom_metrique, memo|
        memo[nom_metrique] = public_send(nom_metrique)
      end
      partie.update(metriques: metriques)
    end

    def score
      resultat = nil

      if temps_moyen_mots_francais.present?
        resultat = temps_moyen_mots_francais * nombre_bonnes_reponses_francais
      end

      if temps_moyen_non_mots.present?
        resultat = nombre_bonnes_reponses_non_mot * temps_moyen_non_mots + (resultat || 0)
      end

      resultat
    end
  end
end
