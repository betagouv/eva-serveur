# frozen_string_literal: true

require 'rails_helper'

describe Compte, type: :integration do
  ActiveJob::Base.queue_adapter = :test

  describe 'après création' do
    it 'programme un mail de relance' do
      expect do
        create :compte_conseiller
      end.to have_enqueued_job(RelanceUtilisateurPourNonActivationJob)
    end

    it 'programme un mail de bienvenue' do
      expect do
        create :compte_conseiller
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end

    context 'quand le compte est superadmin' do
      it 'ne programme pas de mail de relance pour éviter le pb dans le seed par exemple' do
        expect do
          create :compte_superadmin
        end.not_to have_enqueued_job(RelanceUtilisateurPourNonActivationJob)
      end
      it 'ne programme pas de mail de bienvenue' do
        expect do
          create :compte_superadmin
        end.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end
  end

  describe '#find_admins' do
    let(:structure) { create :structure }
    let(:compte) { create :compte_conseiller, structure: structure }

    it "ne trouve aucun admins d'un compte quand il n'y en a pas" do
      expect(compte.find_admins.empty?).to eql(true)
    end

    describe 'avec des admins' do
      let!(:compte_admin) { create :compte_admin, structure: structure }
      let!(:compte_admin2) { create :compte_admin, structure: structure }
      let!(:compte_superadmin) { create :compte_superadmin, structure: structure }
      let(:autre_structure) { create :structure }
      let!(:autre_admin) { create :compte_admin, structure: autre_structure }

      it "trouve les admins d'un compte" do
        expect(compte.find_admins.count).to eql(3)
      end
    end
  end
end
