require 'rails_helper'

describe SituationConfiguration, type: :integration do
  let(:campagne) { create :campagne }
  let(:autre_campagne) { create :campagne }
  let(:livraison) { create :situation_livraison }
  let(:maintenance) { create :situation_maintenance }
  let(:controle) { create :situation_controle }

  before do
    campagne.situations_configurations.create situation: livraison
    campagne.situations_configurations.create situation: maintenance
    autre_campagne.situations_configurations.create situation: controle
  end

  describe '#ids_situations' do
    it "retourne les ids des situations d'une campagne pour les noms techniques" do
      expect(described_class.ids_situations(campagne.id, [ 'livraison' ]))
        .to eql([ livraison.id ])
      expect(described_class.ids_situations(campagne.id, %w[livraison maintenance]))
        .to eql([ livraison.id, maintenance.id ])
      expect(described_class.ids_situations(campagne.id, [ 'controle' ])).to eql([])
    end
  end
end
