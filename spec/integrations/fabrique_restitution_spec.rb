# frozen_string_literal: true

require 'rails_helper'

describe FabriqueRestitution do
  describe '#restitution_globale' do
    context 'instancie uniquement les parties présentes dans la campagne' do
      let(:situation_intrue) { create :situation_tri }
      let!(:partie_intrue) { create :partie, evaluation: evaluation, situation: situation_intrue }
      let(:campagne) { create :campagne, situations_configurations: [] }
      let(:evaluation) { create :evaluation, campagne: campagne }
      let(:restitution_globale) { FabriqueRestitution.restitution_globale evaluation }

      it { expect(restitution_globale.restitutions).to eq [] }
    end
  end
end
