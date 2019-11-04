# frozen_string_literal: true

module Restitution
  class Base
    EVENEMENT = {
      REJOUE_CONSIGNE: 'rejoueConsigne',
      STOP: 'stop'
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
    delegate :session_id, :situation, :date, to: :premier_evenement

    def initialize(campagne, evenements)
      @campagne = campagne
      @evenements = evenements
    end

    def evaluation
      @evenements.first.evaluation
    end

    def supprimer
      Evenement.where(id: evenements.pluck(:id)).delete_all
    end

    def compte_nom_evenements(nom)
      evenements.count { |e| e.nom == nom }
    end

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
      evenements.last.nom == EVENEMENT[:STOP]
    end

    def termine?
      raise NotImplementedError
    end

    def competences
      {}
    end

    def calcule_competences(competences)
      competences.each_with_object({}) do |(competence, classe), resultat|
        resultat[competence] = classe.new(self).niveau
      end
    end

    def efficience
      competences_utilisees = competences.except(*COMPETENCES_INUTILES_POUR_EFFICIENCE)
      return ::Competence::NIVEAU_INDETERMINE if competences_indeterminees?(competences_utilisees)
      return 0 if competences_utilisees.size.zero?

      competences_utilisees.inject(0) do |memo, (_competence, niveau)|
        memo + CORRESPONDANCES_NIVEAUX[niveau]
      end / competences_utilisees.size
    end

    def to_param
      @evenements.first.to_param
    end

    def competences_mobilisees
      return [] unless self.class.const_defined?('COMPETENCES_MOBILISEES')

      self.class.const_get('COMPETENCES_MOBILISEES')
    end

    def premier_evenement_du_nom(evenements, nom_evenement)
      evenements.find { |e| e.nom == nom_evenement }
    end

    private

    def competences_indeterminees?(competences)
      competences.any? do |_competence, niveau|
        niveau == ::Competence::NIVEAU_INDETERMINE
      end
    end
  end
end
