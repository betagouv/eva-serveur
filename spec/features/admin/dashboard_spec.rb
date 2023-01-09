# frozen_string_literal: true

require 'rails_helper'

describe 'Dashboard', type: :feature do
  let!(:ma_structure) { create :structure_locale, :avec_admin }
  let!(:compte) { create :compte_superadmin, structure: ma_structure }

  before { connecte(compte) }

  context 'quand il y a des comptes en attente pour ma structure' do
    before { create :compte_conseiller, statut_validation: :en_attente, structure: ma_structure }

    it "affiche un message d'alerte" do
      visit admin_path
      expect(page).to have_content("Des demandes d'accès sont en attente de validation.")
    end
  end

  context 'quand mon compte est refusé' do
    let!(:compte) do
      create :compte_conseiller, statut_validation: :refusee, structure: ma_structure
    end

    it "affiche l'encart" do
      visit admin_path
      expect(page).to have_content('Votre compte est refusé.')
    end
  end

  context 'quand je suis en mode en tutoriel' do
    let!(:compte) do
      create :compte_conseiller, statut_validation: :acceptee, structure: ma_structure
    end

    it 'affiche la prise en main' do
      visit admin_path
      expect(page).to have_content('Quitter le tutoriel')
    end

    context "quitter le mode tutoriel à n'importe quel moment" do
      it "n'affiche plus la prise en main" do
        expect do
          visit admin_path
          click_on 'Quitter le tutoriel'
        end.to change { compte.reload.mode_tutoriel }.from(true).to(false)
        expect(page).not_to have_content('Quitter le tutoriel')
      end
    end

    context "je n'ai pas encore créé de campagne" do
      it "affiche l'étape création de campagne" do
        visit admin_path
        expect(page).to have_content('Bienvenue sur eva')
        expect(page).to have_content('Créez votre campagne')
        expect(page).not_to have_content('Testez votre campagne')
      end
    end

    context "j'ai créé une campagne mais je n'ai pas fait d'évaluation" do
      let!(:campagne) { create :campagne, compte: compte }

      it "affiche l'étape test de campagne" do
        visit admin_path
        expect(page).not_to have_content('Créez votre campagne')
        expect(page).to have_content('Testez votre campagne')
        expect(page).not_to have_content('Organisez votre première session')
      end
    end

    context "j'ai créé une campagne et j'ai fait une évaluation" do
      let!(:campagne) { create :campagne, compte: compte }
      let!(:evaluation) { create_list :evaluation, 1, campagne: campagne }

      it "affiche l'étape organiser 4 passations" do
        visit admin_path
        expect(page).not_to have_content('Testez votre campagne')
        expect(page).to have_content('Organisez 4 passations')
        expect(page).not_to have_content('fin')
      end
    end

    context "j'ai déjà créé une campagne et j'ai au moins 4 évaluations" do
      let!(:campagne) { create :campagne, compte: compte }
      let!(:evaluation) { create_list :evaluation, 4, campagne: campagne }

      it "affiche l'écran de fin" do
        visit admin_path
        expect(page).to have_content('Vous êtes prêt à utiliser eva')
        expect do
          click_on 'Fermer le tutoriel'
        end.to change { compte.reload.mode_tutoriel }.from(true).to(false)
        expect(page).not_to have_content('Vous êtes prêt à utiliser eva')
      end
    end
  end

  context 'quand je ne suis pas en mode tutoriel' do
    context 'affiche le message de validation en attente' do
      let!(:compte_support) do
        create :compte,
               nom: 'Ma structure',
               prenom: 'Véronique',
               telephone: '06 01 02 03 04',
               email: Eva::EMAIL_SUPPORT
      end

      before do
        compte.update(mode_tutoriel: false)
        compte.validation_en_attente!
      end

      before { visit admin_path }

      it do
        expect(page).to have_content("Elle va bientôt vous permettre d'utiliser eva")
        infos_support =
          'contacter Véronique au 06 01 02 03 04 ou par mail à support@eva.beta.gouv.fr'
        expect(page).to have_content infos_support
      end
    end
  end

  context "quand il n'y a pas de compte en attente pour ma structure" do
    it "n'affiche pas de message d'alerte" do
      visit admin_path
      expect(page).not_to have_content("Des demandes d'accès sont en attente de validation.")
    end
  end

  context 'quand mon compte est un compte générique' do
    let!(:compte) { create :compte_generique, structure: ma_structure }

    it "affiche un message d'incitation à créer un compte personnel" do
      visit admin_path
      expect(page).to have_content(
        'Pour des questions relatives au RGPD ainsi que pour plus de fluidité, ' \
        'les accompagnants qui utilisent eva doivent maintenant créer des comptes individuels.'
      )
    end
  end

  describe "Confirmation d'email" do
    context "quand mon compte n'a jamais été confirmé" do
      before do
        create :compte_conseiller, confirmed_at: nil, structure: ma_structure
        visit admin_path
      end

      it "affiche un message d'alerte" do
        expect(compte.confirmed?).to be false
        expect(compte.unconfirmed_email).to be nil
        expect(page).to have_content('Confirmez votre adresse email')
      end

      it "redirige vers la page de renvoi des instructions avec l'email pré-rempli" do
        click_on 'Renvoyer les instructions de confirmation'

        expect(page).to have_current_path(
          new_compte_confirmation_path(email: compte.email_a_confirmer)
        )
      end
    end

    context "quand une demande de modification d'email est en cours" do
      let!(:compte) do
        create :compte_conseiller, confirmed_at: Date.current - 1.day, structure: ma_structure,
                                   unconfirmed_email: 'nouveau@mail.com'
      end

      it "affiche un message d'alerte" do
        visit admin_path
        expect(compte.confirmed?).to be true
        expect(page).to have_content('Confirmez votre adresse email')
      end
    end

    context 'quand mon compte est confirmé' do
      let!(:compte) do
        create :compte_conseiller, confirmed_at: Date.current - 1.day, structure: ma_structure
      end

      it "n'affiche pas de message d'alerte" do
        visit admin_path
        expect(page).not_to have_content('Confirmez votre adresse email')
      end
    end
  end
end
