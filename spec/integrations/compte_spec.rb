# frozen_string_literal: true

require 'rails_helper'

describe Compte, type: :integration do
  ActiveJob::Base.queue_adapter = :test

  describe 'après création' do
    let!(:structure) { create :structure, :avec_admin }

    it 'programme un mail de relance' do
      expect do
        create :compte_conseiller, structure: structure
      end.to have_enqueued_job(RelanceUtilisateurPourNonActivationJob)
    end

    it "programme un mail de bienvenue et un mail d'alerte" do
      expect do
        create :compte_conseiller, structure: structure
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob).at_least(2)
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
