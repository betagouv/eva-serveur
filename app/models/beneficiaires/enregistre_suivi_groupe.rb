module Beneficiaires
  class EnregistreSuiviGroupe
    EFFECTUEE_VALIDE = [ "true", "false", MiseEnAction::REPONSE_PAS_ENCORE ].freeze

    def initialize(beneficiaire_ids, effectuee_brut, qualification, precision_autre)
      @beneficiaire_ids = beneficiaire_ids
      @effectuee_brut = effectuee_brut
      @qualification = qualification
      @precision_autre = precision_autre
    end

    def call
      return :effectuee_invalide unless EFFECTUEE_VALIDE.include?(@effectuee_brut)

      count = 0
      Beneficiaire.where(id: @beneficiaire_ids).each do |beneficiaire|
        evaluation = evaluation_concernee(beneficiaire)
        next unless evaluation

        evaluation.enregistre_mise_en_action(effectuee)
        if @qualification.present?
          evaluation.reload.mise_en_action.qualifie(effectuee, @qualification, @precision_autre)
        end
        count += 1
      end

      { succes: count }
    end

    private

    def effectuee
      case @effectuee_brut
      when "true" then true
      when "false" then false
      when MiseEnAction::REPONSE_PAS_ENCORE then nil
      end
    end

    def evaluation_concernee(beneficiaire)
      EvaluationEva
        .where(beneficiaire: beneficiaire)
        .where(EvaluationsEva::StatutSuivi.sql_evaluation_suivie)
        .order(debutee_le: :desc)
        .first
    end
  end
end
