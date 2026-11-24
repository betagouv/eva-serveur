module EvaluationsEva
  class TableauDeBordMisesEnAction
    def initialize(ability)
      @evaluations = EvaluationEva.accessible_by(ability)
    end

    def a_renseigner
      @evaluations.illettrisme_potentiel
                  .mise_en_action_a_renseigner
                  .competences_de_base_completes
                  .non_anonymes
                  .order(created_at: :desc)
    end

    # apres : la personne qu'on vient de passer, ou celle à qui on vient de répondre.
    # On la cherche dans @evaluations et pas dans a_renseigner : une personne répondue
    # n'est plus à renseigner, mais sa date sert toujours à trouver la suivante.
    def suivante(apres:)
      reference = @evaluations.find_by(id: apres) if apres.present?
      return a_renseigner.first if reference.blank?

      a_renseigner.where(created_at: ...reference.created_at).first || a_renseigner.first
    end

    def plusieurs_a_renseigner?
      a_renseigner.many?
    end
  end
end
