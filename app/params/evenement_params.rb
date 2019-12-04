# frozen_string_literal: true

class EvenementParams
  class << self
    def from(params)
      permitted = params.permit(
        :date,
        :nom,
        :session_id,
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

      time_formate = Time.at(date.to_i / 1000.0)
      params['date'] = DateTime.parse(time_formate.to_s)
    end
  end
end
