# frozen_string_literal: true

require 'rails_helper'

describe RelanceUtilisateurPourCampagneJob, type: :job do
  let(:campagne) { create :campagne }

  context "quand la campagne n'a pas de passation" do
    it "envoie un email pour relancer l'utilisateur" do
      expect do
        RelanceUtilisateurPourCampagneJob.perform_now(campagne: campagne)
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context 'quand la campagne a des passations' do
    before { create :evaluation, campagne: campagne }

    it 'ne fais rien' do
      expect do
        RelanceUtilisateurPourCampagneJob.perform_now(campagne: campagne)
      end.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end
end
