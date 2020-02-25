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
