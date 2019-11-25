# frozen_string_literal: true

require 'rails_helper'

describe Partie do
  describe "Persistance d'une partie" do
    let(:situation) { create :situation_inventaire }
    let(:evaluation) { create :evaluation }

    it do
      expect { create(:evenement_demarrage, situation: situation, evaluation: evaluation) }
        .to change { Partie.count }.by 1

      expect { create(:evenement_rejoue_consigne, situation: situation, evaluation: evaluation) }
        .to change { Partie.count }.by 0
    end
  end
end
