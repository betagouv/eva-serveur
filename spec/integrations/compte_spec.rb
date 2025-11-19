require 'rails_helper'

describe Compte, type: :integration do
  describe '#envoie_bienvenue' do
    context 'quand le compte est en attente de validation' do
      let!(:structure) { create :structure_locale }

      it 'programme un mail de bienvenue' do
        expect do
          create :compte_admin,
                 structure: structure,
                 confirmed_at: Time.zone.now,
                 email_bienvenue_envoye: false
        end.to have_enqueued_mail(CompteMailer, :nouveau_compte).exactly(1)
      end

      it "attend la validation de l'email pour envoyer les mails" do
        compte = create :compte_admin, structure: structure, confirmed_at: nil
        expect { compte.update(confirmed_at: Time.zone.now) }
          .to have_enqueued_mail(CompteMailer, :nouveau_compte).exactly(1)
      end

      it "Réenvoie les emails d'accueil quand l'utilisateur change d'email" do
        compte = create :compte_admin, structure: structure, confirmed_at: Time.zone.now
        compte.update(email: 'nouvel_email@ut7.fr')
        expect(compte.reload.email_non_confirme?).to be(true)
        expect { compte.update(confirmed_at: Time.zone.now, unconfirmed_email: nil) }
          .to have_enqueued_mail(CompteMailer, :nouveau_compte).exactly(1)
      end

      describe "ne programme pas d'email" do
        it 'Quand les mails ont déjà été envoyé' do
          compte = create :compte_admin, structure: structure, confirmed_at: Time.zone.now
          expect { compte.update(statut_validation: :acceptee) }
            .to have_enqueued_mail(CompteMailer, :nouveau_compte).exactly(0)
        end

        it "Quand le compte n'a pas de structure" do
          expect do
            create :compte_conseiller, :en_attente, structure: nil, confirmed_at: Time.zone.now
          end
            .to have_enqueued_mail(CompteMailer, :nouveau_compte).exactly(0)
        end

        it "Quand l'email n'est pas confirmée" do
          expect { create :compte_admin, structure: structure, confirmed_at: nil }
            .to have_enqueued_mail(CompteMailer, :nouveau_compte).exactly(0)
        end

        it 'Quand les compte est superadmin' do
          expect { create :compte_superadmin, structure: structure, confirmed_at: Time.zone.now }
            .to have_enqueued_mail(CompteMailer, :nouveau_compte).exactly(0)
        end
      end
    end

    describe '#alerte_admins' do
      let!(:structure) { create :structure_locale, :avec_admin }

      it 'Quand le statut est accepté' do
        expect do
          create :compte_conseiller,
                 structure: structure,
                 statut_validation: :acceptee,
                 confirmed_at: Time.zone.now,
                 email_bienvenue_envoye: false
        end.to have_enqueued_mail(CompteMailer, :alerte_admin).exactly(0)
      end

      it "Quand le compte est en attente mais n'a pas de structure" do
        expect do
          create :compte_conseiller,
                 structure: nil,
                 statut_validation: :en_attente,
                 confirmed_at: Time.zone.now,
                 email_bienvenue_envoye: false
        end.to have_enqueued_mail(CompteMailer, :alerte_admin).exactly(0)
      end

      it 'Quand le statut est en attente' do
        expect do
          create :compte_conseiller,
                 structure: structure,
                 statut_validation: :en_attente,
                 confirmed_at: Time.zone.now,
                 email_bienvenue_envoye: false
        end.to have_enqueued_mail(CompteMailer, :alerte_admin).exactly(1)
      end
    end

    describe '#programme_email_relance' do
      context "quand le compte fait partie d'une structure locale" do
        let(:structure) { create :structure_locale }

        it 'programme un mail de relance' do
          expect do
            create :compte_admin,
                   structure: structure,
                   confirmed_at: Time.zone.now,
                   email_bienvenue_envoye: false
          end.to have_enqueued_job(RelanceUtilisateurPourNonActivationJob).exactly(1)
        end
      end

      context "quand le compte fait partie d'une structure administrative" do
        let(:structure) { create :structure_administrative }

        it 'ne programme pas de mail de relance' do
          expect do
            create :compte_admin,
                   structure: structure,
                   confirmed_at: Time.zone.now,
                   email_bienvenue_envoye: false
          end.to have_enqueued_job(RelanceUtilisateurPourNonActivationJob).exactly(0)
        end
      end

      context "quand le compte ne fait partie d'une structure" do
        it 'ne programme pas de mail de relance' do
          expect do
            create :compte_conseiller,
                   :en_attente,
                   structure: nil,
                   confirmed_at: Time.zone.now,
                   email_bienvenue_envoye: false
          end.to have_enqueued_job(RelanceUtilisateurPourNonActivationJob).exactly(0)
        end
      end
    end
  end
end
