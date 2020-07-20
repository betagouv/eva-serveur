# frozen_string_literal: true

class EvenementParams
  class << self
    def from(params)
      permitted = params.permit(
        :date,
        :nom,
        :session_id,
        :position,
        donnees: {}
      )
      formate!(permitted)
      permitted
    end

    private

    def formate!(params)
      formate_date!(params)
    end

    def formate_date!(params)
      date = params['date']
      return if date.blank?

      params['date'] = Time.strptime(date.to_s, '%Q')
    end
  end
end
