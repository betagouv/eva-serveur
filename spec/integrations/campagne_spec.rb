# frozen_string_literal: true

require 'rails_helper'

describe Campagne, type: :integration do
  context 'pour une campagne sans évaluation' do
    let(:campagne) { create :campagne }
    let(:situation) { create :situation_inventaire }

    before { campagne.situations << situation }

    it 'supprime les dépendances' do
      expect do
        campagne.destroy
      end.to change { described_class.count }.by(-1)
                                             .and change { SituationConfiguration.count }.by(-1)
    end
  end
end
