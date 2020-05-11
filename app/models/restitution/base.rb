# frozen_string_literal: true

module Restitution
  class Base
    EVENEMENT = {
      FIN_SITUATION: 'finSituation',
      REJOUE_CONSIGNE: 'rejoueConsigne',
      ABANDON: 'abandon'
    }.freeze

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
    alias date created_at

    def initialize(campagne, evenements)
      @campagne = campagne
      @evenements = evenements
    end

    def persiste
      nom_restitution = self.class.name
      return unless nom_restitution.constantize.const_defined?('METRIQUES')

      dictionnaire_metriques = "#{nom_restitution}::METRIQUES".constantize
      metriques = dictionnaire_metriques.keys.each_with_object({}) do |nom_metrique, memo|
        memo[nom_metrique] = public_send(nom_metrique)
      end
      partie.update(metriques: metriques)
    end

    def supprimer
      partie.destroy
    end

    def partie
      @partie ||= premier_evenement.partie
    end

    def compte_nom_evenements(nom)
      evenements.count { |e| e.nom == nom }
    end

    # Deprecated: utiliser la règle Base::TempsTotal à la place
    def temps_total
      evenements.last.date - evenements.first.date
    end

    def premier_evenement
      evenements.first
    end

    def nombre_rejoue_consigne
      compte_nom_evenements EVENEMENT[:REJOUE_CONSIGNE]
    end

    def abandon?
      evenements.last.nom == EVENEMENT[:ABANDON]
    end

    def termine?
      evenements.last.nom == EVENEMENT[:FIN_SITUATION]
    end

    def competences_de_base
      {}
    end

    def competences
      {}
    end

    def calcule_competences(competences)
      competences.transform_values { |classe| classe.new(self).niveau }
    end

    def efficience
      competences_utilisees = competences.except(*COMPETENCES_INUTILES_POUR_EFFICIENCE)
      return ::Competence::NIVEAU_INDETERMINE if competences_indeterminees?(competences_utilisees)
      return 0 if competences_utilisees.size.zero?

      competences_utilisees.inject(0) do |memo, (_competence, niveau)|
        memo + CORRESPONDANCES_NIVEAUX[niveau]
      end / competences_utilisees.size
    end

    def score; end

    def to_param
      partie.id
    end

    def display_name
      "#{evaluation.nom} - #{situation.libelle}"
    end

    private

    def competences_indeterminees?(competences)
      competences.any? do |_competence, niveau|
        niveau == ::Competence::NIVEAU_INDETERMINE
      end
    end
  end
end
