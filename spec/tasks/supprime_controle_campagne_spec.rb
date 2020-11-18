# frozen_string_literal: true

require 'rails_helper'

describe 'nettoyage:supprime_controle_campagne' do
  include_context 'rake'

  context "d'une campagne vide" do
    let(:campagne) { create :campagne }

    it do
      subject.invoke
      expect(campagne.situations.count).to eql(0)
    end
  end

  context 'une campagnes avec controle' do
    let(:campagne) { create :campagne }
    let(:situation_controle) { create :situation_controle }
    let(:situation_inventaire) { create :situation_inventaire }

    before do
      campagne.situations << situation_controle
      campagne.situations << situation_inventaire
    end

    it do
      subject.invoke
      expect(campagne.reload.situations.count).to eql(1)
      expect(campagne.reload.situations[0].nom_technique).to eql('inventaire')
    end
  end

  context "d'une campagne sans controle" do
    let(:campagne) { create :campagne }
    let(:situation) { create :situation_inventaire }

    before { campagne.situations << situation }

    it do
      subject.invoke
      expect(campagne.reload.situations.count).to eql(1)
    end
  end
end
