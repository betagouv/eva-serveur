# frozen_string_literal: true

module Restitution
  class Base
    CORRESPONDANCES_NIVEAUX = {
      ::Competence::NIVEAU_4 => 100,
      ::Competence::NIVEAU_3 => 75,
      ::Competence::NIVEAU_2 => 50,
      ::Competence::NIVEAU_1 => 25
    }.freeze

    COMPETENCES_INUTILES_POUR_EFFICIENCE = [
      ::Competence::PERSEVERANCE,
      ::Competence::COMPREHENSION_CONSIGNE
    ].freeze

    attr_reader :campagne, :evenements

    delegate :evaluation, :session_id, :situation, :created_at, to: :partie
    delegate :moyennes_metriques, :ecarts_types_metriques, to: :standardisateur
    delegate :partie, :compte_nom_evenements, :temps_total,
             :premier_evenement, :dernier_evenement,
             :nombre_rejoue_consigne, :abandon?, :termine?,
             to: :evenements_helper

    alias date created_at

    def initialize(campagne, evenements)
      @campagne = campagne
      @evenements = evenements
    end

    def persiste
      nom_restitution = self.class.name
      return unless nom_restitution.constantize.const_defined?("METRIQUES")

      dictionnaire_metriques = "#{nom_restitution}::METRIQUES".constantize
      metriques = dictionnaire_metriques.keys.index_with do |nom_metrique|
        public_send(nom_metrique)
      end
      partie.update(metriques: metriques)
    end

    def supprimer
      partie.destroy
    end

    def competences_de_base
      {}
    end

    def competences
      {}
    end

    def synthese
      {
        efficience: efficience
      }
    end

    def calcule_competences(competences)
      competences.transform_values { |classe| classe.new(self).niveau }
    end

    def efficience
      competences_utilisees = competences.except(*COMPETENCES_INUTILES_POUR_EFFICIENCE)
      return ::Competence::NIVEAU_INDETERMINE if competences_indeterminees?(competences_utilisees)
      return 0 if competences_utilisees.empty?

      competences_utilisees.inject(0) do |memo, (_competence, niveau)|
        memo + CORRESPONDANCES_NIVEAUX[niveau]
      end / competences_utilisees.size
    end

    def cote_z_metriques
      @cote_z_metriques ||= partie.metriques.each_with_object({}) do |(metrique, valeur), memo|
        memo[metrique] = standardisateur.standardise(metrique, valeur)
      end
    end

    def score; end

    def to_param
      partie.id
    end

    def display_name
      "#{evaluation.display_name} - #{situation.libelle}"
    end

    private

    def evenements_helper
      @evenements_helper ||= Restitution::Base::EvenementsHelper.new(@evenements)
    end

    def competences_indeterminees?(competences)
      competences.any? do |_competence, niveau|
        niveau == ::Competence::NIVEAU_INDETERMINE
      end
    end

    def standardisateur
      @standardisateur ||= Restitution::StandardisateurGlissant.new(
        partie.metriques_numeriques,
        proc { Partie.where(situation: partie.situation) },
        Restitution::StandardisateurFige::STANDARDS[partie.situation.nom_technique.to_sym]
      )
    end
  end
end
