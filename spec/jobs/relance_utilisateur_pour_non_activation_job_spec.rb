# frozen_string_literal: true

require 'rails_helper'

describe RelanceUtilisateurPourNonActivationJob, type: :job do
  let(:compte) { create :compte_admin, email_bienvenue_envoye: false }

  context "quand le compte n'a pas de campagne" do
    it "envoie un email pour relancer l'utilisateur" do
      expect do
        described_class.perform_now(compte.id)
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end

  context 'quand le compte a une ou plusieurs campagne sans passation' do
    let(:campagne) { create :campagne, compte: compte }

    it "envoie un email pour relancer l'utilisateur" do
      expect do
        described_class.perform_now(compte.id)
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end

  context 'quand le compte a une campagne avec des passations' do
    let(:campagne) { create :campagne, compte: compte }

    before { create :evaluation, campagne: campagne }

    it 'ne fais rien' do
      expect do
        described_class.perform_now(compte.id)
      end.not_to(change { ActionMailer::Base.deliveries.count })
    end
  end

  context 'quand le compte a une campagne sans passations et pas de structure' do
    let(:campagne) { create :campagne, compte: compte }

    before do
      compte.update(structure_id: nil)
    end

    it 'ne fais rien' do
      expect do
        described_class.perform_now(compte.id)
      end.not_to(change { ActionMailer::Base.deliveries.count })
    end
  end

  context 'quand le compte a été supprimé' do
    it do
      id_compte_supprime = 1
      expect do
        described_class.perform_now(id_compte_supprime)
      end.not_to(change { ActionMailer::Base.deliveries.count })
    end
  end
end
