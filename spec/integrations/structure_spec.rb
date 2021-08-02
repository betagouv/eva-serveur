# frozen_string_literal: true

require 'rails_helper'

describe Structure, type: :integration do
  describe 'scopes' do
    describe 'sans_campagne' do
      let!(:structure) { create :structure }
      context 'sans aucune campagne' do
        it { expect(Structure.sans_campagne.count).to eq 1 }
      end

      context 'avec au moins une campagne' do
        before do
          compte = create :compte, structure: structure
          create :campagne, compte: compte
        end
        it { expect(Structure.sans_campagne.count).to eq 0 }
      end
    end
  end
end
