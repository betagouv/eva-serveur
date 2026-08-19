module Restitution
  class Globale
    attr_reader :evaluation, :restitutions

    delegate :id, to: :evaluation

    def initialize(evaluation:, restitutions:, restitutions_dernier_essai:)
      @evaluation = evaluation
      @restitutions = restitutions
      @restitutions_dernier_essai = restitutions_dernier_essai
    end

    def date
      evaluation.created_at
    end

    def structure
      evaluation.campagne.compte.structure&.nom
    end

    def selectionne_derniere_restitution(nom)
      @restitutions_dernier_essai.find { |restitution| restitution.situation.nom_technique == nom }
    end
  end
end
