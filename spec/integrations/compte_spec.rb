# frozen_string_literal: true

require 'rails_helper'

describe Compte, type: :integration do
  describe 'après création' do
    context 'quand le compte est en attente de validation' do
      let!(:structure) { create :structure_locale, :avec_admin }

      it "programme un mail de relance, un mail de bienvenue et un mail d'alerte aux admins" do
        expect { create :compte_conseiller, structure: structure, statut_validation: :en_attente }
          .to have_enqueued_mail(
            CompteMailer,
            :nouveau_compte
          ).exactly(1)
          .and have_enqueued_mail(
            CompteMailer,
            :alerte_admin
          ).exactly(1)
          .and have_enqueued_job(RelanceUtilisateurPourNonActivationJob).exactly(1)
      end

      it "ne programme pas d'email si c'est une modification du compte" do
        compte = create :compte_conseiller, structure: structure, statut_validation: :en_attente
        expect { compte.update(statut_validation: :acceptee) }
          .to have_enqueued_mail(
            CompteMailer,
            :nouveau_compte
          ).exactly(0)
      end
    end

    context 'quand le compte est superadmin' do
      it 'ne programme pas de mail' do
        expect { create :compte_superadmin }
          .to have_enqueued_mail(
            CompteMailer,
            :nouveau_compte
          ).exactly(0)
          .and have_enqueued_mail(
            CompteMailer,
            :alerte_admin
          ).exactly(0)
          .and have_enqueued_job(RelanceUtilisateurPourNonActivationJob).exactly(0)
      end
    end

    context "quand le compte n'est pas en attente" do
      it 'programme un mail de relance et un mail de bienvenue' do
        expect { create :compte_admin, statut_validation: :acceptee }
          .to have_enqueued_mail(
            CompteMailer,
            :nouveau_compte
          ).exactly(1)
          .and have_enqueued_mail(
            CompteMailer,
            :alerte_admin
          ).exactly(0)
          .and have_enqueued_job(RelanceUtilisateurPourNonActivationJob).exactly(1)
      end
    end

    context "quand le compte fait partie d'une structure locale" do
      let(:structure) { create :structure_locale }

      it 'programme un mail de relance' do
        expect { create :compte_admin, statut_validation: :acceptee, structure: structure }
          .to have_enqueued_job(RelanceUtilisateurPourNonActivationJob).exactly(1)
      end
    end

    context "quand le compte fait partie d'une structure administrative" do
      let(:structure) { create :structure_administrative }

      it 'programme un mail de relance' do
        expect { create :compte_admin, statut_validation: :acceptee, structure: structure }
          .not_to have_enqueued_job(RelanceUtilisateurPourNonActivationJob).exactly(1)
      end
    end
  end

  describe '#find_admins' do
    let(:structure) { create :structure_locale }
    let(:compte) { create :compte_conseiller, structure: structure }

    describe 'avec des admins' do
      let!(:compte_admin) { create :compte_admin, structure: structure }
      let!(:compte_admin2) { create :compte_admin, structure: structure }
      let!(:compte_superadmin) { create :compte_superadmin, structure: structure }
      let(:autre_structure) { create :structure }
      let!(:autre_admin) { create :compte_admin, structure: autre_structure }

      it "trouve les admins d'un compte" do
        expect(compte.find_admins.count).to be(3)
      end
    end
  end
end
