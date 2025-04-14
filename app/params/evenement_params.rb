# frozen_string_literal: true

class EvenementParams
  class << self
    def from(params)
      evenement_params = params.clone
      evenement_params.delete(:situation)
      evenement_params.delete(:evaluation_id)
      formate!(evenement_params)
      evenement_params
    end

    private

    def formate!(params)
      formate_date!(params)
    end

    def formate_date!(params)
      date = params[:date]
      return if date.blank?

      params[:date] = Time.strptime(date.to_s, "%Q")
    end
  end
end
