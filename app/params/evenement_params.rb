# frozen_string_literal: true

class EvenementParams
  def self.from(params)
    params.permit(
      :date,
      :nom,
      :session_id,
      :situation,
      :utilisateur,
      donnees: {}
    )
  end
end
