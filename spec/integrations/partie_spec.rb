# frozen_string_literal: true

require 'rails_helper'

describe Partie do
  context '#moyenne_metrique' do
    let(:situation)  { create :situation_securite }
    let(:evaluation) { create :evaluation }
    let!(:partie1) do
      create :partie,
             situation: situation,
             evaluation: evaluation,
             session_id: '1',
             metriques: { test_metrique: 1 }
    end
    let!(:partie2) do
      create :partie,
             situation: situation,
             evaluation: evaluation,
             session_id: '2',
             metriques: { test_metrique: 0 }
    end

    it 'calcule la moyenne' do
      expect(partie1.moyenne_metrique(:test_metrique)).to eql(0.5)
    end
  end
end
