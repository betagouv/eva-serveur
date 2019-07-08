# frozen_string_literal: true

require 'rails_helper'

describe EvaluationParams do
  describe '#from' do
    it 'filtre les parametres' do
      params = ActionController::Parameters.new(
        nom: 'mon nom',
        autre_param: 'autre paramètre'
      )

      evaluation_params = described_class.from(params)
      expect(evaluation_params.keys.sort).to eql(
        %w[campagne nom]
      )
    end
  end
end
