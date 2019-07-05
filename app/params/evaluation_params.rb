# frozen_string_literal: true

class EvaluationParams
  def self.from(params)
    params.permit(
      :nom
    )
  end
end
