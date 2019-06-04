# frozen_string_literal: true

module Evaluation
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

    attr_reader :evenements
    delegate :session_id, :utilisateur, :situation, :date, to: :premier_evenement

    def initialize(evenements)
      @evenements = evenements
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

    def efficience
      competences_utilisees = competences.except(
        ::Competence::PERSEVERANCE,
        ::Competence::COMPREHENSION_CONSIGNE
      ).reject do |_competence, niveau|
        niveau == ::Competence::NIVEAU_INDETERMINE
      end
      return nil if competences_utilisees.size.zero?

      competences_utilisees.inject(0) do |memo, (_competence, niveau)|
        memo + CORRESPONDANCES_NIVEAUX[niveau]
      end / competences_utilisees.size
    end
  end
end
