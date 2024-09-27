# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationAdminComptesEnAttenteJob, type: :job do
  context "quand l'admin a toujours des comptes en attente de validation" do
    let!(:structure) { create :structure_locale }
    let!(:compte) { create :compte_admin, structure: structure }
    let!(:compte) { create :compte, statut_validation: :en_attente, structure: structure }

    it "envoie un mail hebdomadairement pour relancer l'admin" do
      expect do
        described_class.perform_now
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
