# frozen_string_literal: true

require 'rails_helper'

describe RelanceStructureSansCampagneJob, type: :job do
  let(:compte_admin) { create :compte_admin }
  let!(:compte_admin_autre) { create :compte_admin, structure: compte_admin.structure }
  let!(:compte_conseiller) { create :compte_conseiller, structure: compte_admin.structure }

  context "quand la structure n'a pas de campagne" do
    it 'envoie un email pour relancer uniquement les admins' do
      expect do
        described_class.perform_now(compte_admin.structure_id)
      end.to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end

  context 'quand la structure a déjà une campagne' do
    let!(:campagne) { create :campagne, compte: compte_admin }

    it "n'envoie pas de mail pour relancer l'admin" do
      expect do
        described_class.perform_now(compte_admin.structure_id)
      end.not_to(change { ActionMailer::Base.deliveries.count })
    end
  end
end
