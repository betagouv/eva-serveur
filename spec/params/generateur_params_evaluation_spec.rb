# frozen_string_literal: true

require 'rails_helper'

describe GenerateurParamsEvaluation do
  describe '#from' do
    it 'filtre les parametres' do
      params = ActionController::Parameters.new(
        nom: 'mon nom',
        autre_param: 'autre paramètre',
        code_campagne: 'code campagne inexistant'
      )

      evaluation_params = described_class.new(params)
      expect(evaluation_params.params.keys.sort).to eql(
        %w[campagne nom]
      )
      expect(evaluation_params.code_campagne_inconnu).to eql(true)
    end
  end
end
