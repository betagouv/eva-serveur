# frozen_string_literal: true

require 'rails_helper'

describe 'Dashboard', type: :feature do
  let!(:ma_structure) { create :structure, :avec_admin }
  let!(:compte) { create :compte_superadmin, structure: ma_structure }
  before { connecte(compte) }

  context 'quand il y a des comptes en attente pour ma structure' do
    before { create :compte, statut_validation: :en_attente, structure: ma_structure }

    describe 'je suis admin' do
      it "affiche un message d'alerte" do
        visit admin_path
        expect(page).to have_content("Des demandes d'accès sont en attente de validation.")
      end
    end

    describe 'je suis conseiller' do
      let!(:compte) do
        create :compte_conseiller, structure: ma_structure
      end

      it "n'affiche pas un message d'alerte" do
        visit admin_path
        expect(page).not_to have_content("Des demandes d'accès sont en attente de validation.")
      end
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
        'Nous déconseillons de partager un accès, vous pouvez créer votre compte personnel ici'
      )
    end
  end

  describe 'Encart de bienvenue' do
    context 'lorsque je me suis connecté plus de 4 fois' do
      let(:compte) { create :compte_admin, sign_in_count: 5 }

      context "je n'ai pas encore créé de campagne" do
        it "affiche l'encart" do
          visit admin_path
          expect(page).to have_content('Bienvenue dans votre espace conseiller !')
          expect(page).to have_content('Eva utilise le concept de "campagne" pour regrouper les ' \
                                       'passations selon leurs objectifs, leurs publics cibles ' \
                                       'ou les dispositifs mobilisés.')
          expect(page).not_to have_content('Organisez votre première session puis retrouvez ici ' \
                                           'vos dernières évaluations.')
        end
      end

      context "j'ai déjà créé une campagne et j'ai des évaluations" do
        let!(:campagne) { create :campagne, compte: compte }
        let!(:evaluation) { create_list :evaluation, 2, campagne: campagne }

        it "n'affiche pas d'encart " do
          visit admin_path
          expect(page).not_to have_content('Bienvenue dans votre espace conseiller !')
          expect(page).not_to have_content('Organisez votre première session puis retrouvez ici ' \
                                           'vos dernières évaluations.')
          expect(page).not_to have_content('Eva utilise le concept de "campagne" pour regrouper ' \
                                           'les passations selon leurs objectifs, leurs publics ' \
                                           'cibles ou les dispositifs mobilisés.')
        end

        context 'affiche le message de validation en attente' do
          let!(:compte_support) do
            create :compte,
                   nom: 'Ma structure',
                   prenom: 'Véronique',
                   telephone: '06 01 02 03 04',
                   email: Eva::EMAIL_SUPPORT
          end

          before { compte.validation_en_attente! }
          before { visit admin_path }
          it do
            expect(page).to have_content("Elle va bientôt vous permettre d'utiliser eva")
            infos_support =
              'contacter Véronique au 06 01 02 03 04 ou par mail à support@eva.beta.gouv.fr'
            expect(page).to have_content infos_support
          end
        end
      end
    end
  end
end
