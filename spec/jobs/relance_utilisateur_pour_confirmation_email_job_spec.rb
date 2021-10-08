# frozen_string_literal: true

require 'rails_helper'

fdescribe RelanceUtilisateurPourConfirmationEmailJob, type: :job do
  let(:compte) { create :compte }

  describe "quand le compte n'a pas été confirmé" do
    it "envoie l'email de confirmation" do
      compte.update(confirmed_at: nil)

      expect do
        RelanceUtilisateurPourConfirmationEmailJob.perform_now
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end

  describe 'quand le compte a été confirmé' do
    it "n'envoie pas l'email de confirmation" do
      compte.update(confirmed_at: 2.days.ago)

      expect do
        RelanceUtilisateurPourConfirmationEmailJob.perform_now
      end.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end
end
