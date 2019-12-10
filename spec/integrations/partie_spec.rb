# frozen_string_literal: true

require 'rails_helper'

describe Partie do
  let(:situation)  { create :situation_securite }
  let(:evaluation) { create :evaluation }
  let(:partie1) do
    create :partie,
           situation: situation,
           evaluation: evaluation,
           session_id: '1',
           metriques: {
             test_metrique: 1,
             test_metrique_tableau: [1, 2],
             test_chaine: 'test1'
           }
  end
  let(:partie2) do
    create :partie,
           situation: situation,
           evaluation: evaluation,
           session_id: '2',
           metriques: {
             test_metrique: 0,
             test_metrique_tableau: [2, 3],
             test_chaine: 'test2'
           }
  end

  let(:partie3) do
    create :partie,
           situation: situation,
           evaluation: evaluation,
           session_id: '3',
           metriques: {
             test_metrique: 2,
             test_metrique_tableau: [2, 3],
             test_chaine: 'test2'
           }
  end

  context '#moyenne_metrique' do
    before { [partie1, partie2, partie3] }

    it 'calcule la moyenne' do
      expect(partie1.moyenne_metrique(:test_metrique)).to eql(1.0)
    end
  end

  context '#moyenne_metriques' do
    context "calcule la moyenne pour l'ensemble des metriques" do
      before { [partie1, partie2, partie3] }

      it do
        expect(partie1.moyenne_metriques).to eql('test_chaine' => nil,
                                                 'test_metrique' => 1.0,
                                                 'test_metrique_tableau' => nil)
      end
    end

    it "lorsqu'il n'y a aucune partie enregistré" do
      partie1.update(metriques: {})
      expect(partie1.moyenne_metriques).to be_nil
    end
  end

  context '#ecart_type_metrique' do
    before { [partie1, partie2, partie3] }

    it "calcule l'écart type" do
      expect(partie1.ecart_type_metrique(:test_metrique)).to eql(0.82)
    end
  end

  context '#ecart_type_metriques' do
    context "calcule la moyenne pour l'ensemble des metriques" do
      before { [partie1, partie2, partie3] }

      it do
        expect(partie1.ecart_type_metriques).to eql('test_chaine' => nil,
                                                    'test_metrique' => 0.82,
                                                    'test_metrique_tableau' => nil)
      end
    end

    it "lorsqu'il n'y a aucune partie enregistré" do
      partie1.update(metriques: {})
      expect(partie1.ecart_type_metriques).to be_nil
    end
  end
end
