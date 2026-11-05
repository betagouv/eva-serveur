module Beneficiaires
  class EnregistreSuiviGroupe
    EFFECTUEE_VALIDE = [ "true", "false", MiseEnAction::REPONSE_JE_NE_SAIS_PAS ].freeze

    def initialize(beneficiaire_ids, effectuee_brut, qualification, precision_autre)
      @beneficiaire_ids = beneficiaire_ids
      @effectuee_brut = effectuee_brut
      @qualification = qualification
      @precision_autre = precision_autre
    end

    def call
      return :effectuee_invalide unless EFFECTUEE_VALIDE.include?(@effectuee_brut)

      Beneficiaire.where(id: @beneficiaire_ids).each do |beneficiaire|
        evaluation = evaluation_concernee(beneficiaire)
        next unless evaluation

        evaluation.enregistre_mise_en_action(effectuee)
        if @qualification.present?
          evaluation.mise_en_action.qualifie(effectuee, @qualification, @precision_autre)
        end
      end

      :succes
    end

    private

    def effectuee
      case @effectuee_brut
      when "true" then true
      when "false" then false
      when MiseEnAction::REPONSE_JE_NE_SAIS_PAS then nil
      end
    end

    def evaluation_concernee(beneficiaire)
      EvaluationEva
        .where(beneficiaire: beneficiaire)
        .where(EvaluationsEva::StatutSuivi.condition_concernee)
        .order(debutee_le: :desc)
        .first
    end
  end
end
