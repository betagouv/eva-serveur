# frozen_string_literal: true

class EvaluationParams
  class << self
    def from(params)
      permitted = params.permit(
        :nom,
        :code_campagne
      )
      relie_campagne!(permitted)
      permitted
    end

    private

    def relie_campagne!(params)
      code_campagne = params.delete('code_campagne')
      campagne = Campagne.find_by code: code_campagne
      campagne ||= Campagne.first
      params['campagne'] = campagne
    end
  end
end
