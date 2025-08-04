# frozen_string_literal: true

module Api
  class BeneficiairesController < Api::BaseController
    before_action :trouve_beneficiaire

    def show; end

    private

    def trouve_beneficiaire
      @beneficiaire = Beneficiaire.find_by!(code_beneficiaire: params[:code_beneficiaire])
    end
  end
end
