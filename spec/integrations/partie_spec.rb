# frozen_string_literal: true

require 'rails_helper'

describe Partie do
  let(:situation)  { create :situation_securite }
  let(:evaluation) { create :evaluation }
  let!(:partie1) do
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
  let!(:partie2) do
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

  context '#moyenne_metrique' do
    it 'calcule la moyenne' do
      expect(partie1.moyenne_metrique(:test_metrique)).to eql(0.5)
    end
  end

  context '#moyenne_metriques' do
    it "calcule la moyenne pour l'ensemble des metriques" do
      expect(partie1.moyenne_metriques).to eql('test_chaine' => nil,
                                               'test_metrique' => 0.5,
                                               'test_metrique_tableau' => nil)
    end

    it "lorsqu'il n'y a aucune partie enregistré" do
      partie2.destroy
      partie1.update(metriques: {})
      expect(partie1.moyenne_metriques).to be_nil
    end
  end
end
