# frozen_string_literal: true

class GenerateurParamsEvaluation
  attr_reader :code_campagne_inconnu, :params

  def initialize(params)
    @params = params.permit(
      :nom,
      :code_campagne,
      :email,
      :telephone
    )
    relie_campagne
  end

  private

  def relie_campagne
    code_campagne = @params.delete('code_campagne')
    return if code_campagne.blank?

    campagne = Campagne.find_by code: code_campagne
    @code_campagne_inconnu = campagne.nil?
    @params['campagne'] = campagne
  end
end
