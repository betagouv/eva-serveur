# frozen_string_literal: true

require 'rails_helper'

describe 'Dashboard', type: :feature do
  let!(:ma_structure) { create :structure_locale, :avec_admin }
  let!(:compte) { create :compte_superadmin, structure: ma_structure, cgu_acceptees: true }

  before { connecte(compte) }

  context "quand les CGU n'ont pas encore été acceptées" do
    before { compte.update(cgu_acceptees: nil) }

    it "affiche la modal d'acceptation des CGU" do
      visit admin_path
      expect(page).to have_content("Conditions Générales d'Utilisation")
      click_on 'J’ai lu et j’accepte les CGU'
      expect(compte.reload.cgu_acceptees).to be(true)
    end
  end

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

  context 'quand je suis avec un compte sans structure' do
    let!(:compte) do
      create :compte_conseiller, statut_validation: :acceptee, structure: nil
    end

    it 'Affiche le tutoriel sans le bouton quitter' do
      visit admin_path
      expect(page).to have_content('Bien débuter')
      expect(page).not_to have_content('Quitter le tutoriel')
    end
  end

  context 'quand je suis avec un compte avec une structure' do
    let!(:compte) do
      create :compte_conseiller, statut_validation: :acceptee, structure: ma_structure
    end

    it 'affiche le tutoriel avec un bouton quitter' do
      visit admin_path
      expect(page).to have_content('Bien débuter')
      expect(page).to have_content('Quitter le tutoriel')
    end

    it 'peut quitter le mode tutoriel' do
      expect do
        visit admin_path
        click_on 'Quitter le tutoriel'
      end.to change { compte.reload.mode_tutoriel }.from(true).to(false)
      expect(page).not_to have_content('Quitter le tutoriel')
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

      it "affiche l'étape valider son email" do
        visit admin_path
        expect(compte.confirmed?).to be false
        expect(compte.unconfirmed_email).to be nil
        expect(page).not_to have_content('Testez votre campagne')
        expect(page).to have_content('Confirmez votre adresse email')
        expect(page).not_to have_content('Testez votre campagne')
      end

      it "redirige vers la page de renvoi des instructions avec l'email pré-rempli" do
        visit admin_path
        click_on 'Renvoyer les instructions de confirmation'

        expect(page).to have_current_path(
          new_compte_confirmation_path(email: compte.email_a_confirmer)
        )
      end
    end

    context "après l'étape de confirmation d'email" do
      let!(:campagne) { create :campagne, compte: compte }
      let!(:evaluation) { create_list :evaluation, 1, campagne: campagne }

      before { compte.update(confirmed_at: Time.zone.today) }

      it "affiche l'étape organiser 4 passations" do
        visit admin_path
        expect(page).not_to have_content('Confirmez votre email')
        expect(page).to have_content('Organisez 4 passations')
        expect(page).not_to have_content('fin')
      end
    end

    context "j'ai déjà créé une campagne et j'ai au moins 4 évaluations" do
      let!(:campagne) { create :campagne, compte: compte }
      let!(:evaluation) { create_list :evaluation, 4, campagne: campagne }

      before { compte.update(confirmed_at: Time.zone.today) }

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
end
