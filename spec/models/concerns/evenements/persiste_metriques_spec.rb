# frozen_string_literal: true

require 'rails_helper'

describe Evenements::PersisteMetriques do
  context 'avec un événement quelconque' do
    let(:evenement) { build :evenement_abandon }
    it "sauve l'évenement mais ne persiste pas les métriques" do
      expect { evenement.save }
        .not_to have_enqueued_job(PersisteMetriquesPartieJob)
    end
  end

  context 'avec un événement fin' do
    let(:evenement_fin) { build :evenement_fin_situation }

    it 'persiste les métriques de la partie quand il se sauve' do
      expect { evenement_fin.save }
        .to have_enqueued_job(PersisteMetriquesPartieJob).exactly(1)
    end
  end
end
