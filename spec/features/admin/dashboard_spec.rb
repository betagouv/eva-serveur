# frozen_string_literal: true

require 'rails_helper'

describe 'Dashboard', type: :feature do
  let!(:ma_structure) { create :structure, :avec_admin }
  let!(:compte) { create :compte_superadmin, structure: ma_structure }
  before { connecte(compte) }

  context 'quand il y a des comptes en attente pour ma structures' do
    before { create :compte, statut_validation: :en_attente, structure: ma_structure }
    it "affiche un message d'alerte" do
      visit admin_path
      expect(page).to have_content("Des demandes d'accès sont en attente de validation.")
    end
  end

  context "quand il n'y a pas de compte en attente pour ma structures" do
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
    context 'lorsque je me suis connecté 4 fois ou moins' do
      let(:compte) { create :compte_admin, sign_in_count: 3 }

      context "je n'ai pas encore créé de campagne" do
        it "affiche l'encart concernant les campagnes" do
          visit admin_path
          expect(page).to have_content('Bienvenue dans votre espace conseiller !')
          expect(page).to have_content('Eva utilise le concept de "campagne" pour regrouper les ' \
                                       'passations selon leurs objectifs, leurs publics cibles ' \
                                       'ou les dispositifs mobilisés.')
          expect(page).not_to have_content('Organisez votre première session puis retrouvez ici ' \
                                           'vos dernières évaluations.')
        end
      end

      context "j'ai déjà créé une campagne mais pas d'évaluation" do
        let!(:campagne) { create :campagne, compte: compte }

        it "affiche l'encart concernant les évaluations" do
          visit admin_path
          expect(page).to have_content('Bienvenue dans votre espace conseiller !')
          expect(page).to have_content('Organisez votre première session puis retrouvez ici vos ' \
                                       'dernières évaluations.')
          expect(page).not_to have_content('Eva utilise le concept de "campagne" pour regrouper ' \
                                           'les passations selon leurs objectifs, leurs publics ' \
                                           'cibles ou les dispositifs mobilisés.')
        end
      end

      context "j'ai déjà créé une campagne et j'ai des évaluations" do
        let!(:campagne) { create :campagne, compte: compte }
        let!(:evaluation) { create :evaluation, campagne: campagne }

        it "affiche l'encart concernant les évaluations" do
          visit admin_path
          expect(page).to have_content('Bienvenue dans votre espace conseiller !')
          expect(page).to have_content('Organisez votre première session puis retrouvez ici vos ' \
                                       'dernières évaluations.')
          expect(page).not_to have_content('Eva utilise le concept de "campagne" pour regrouper ' \
                                           'les passations selon leurs objectifs, leurs publics ' \
                                           'cibles ou les dispositifs mobilisés.')
        end
      end
    end

    context 'lorsque je me suis connecté plus de 4 fois' do
      let(:compte) { create :compte_admin, sign_in_count: 5 }

      context "je n'ai pas encore créé de campagne" do
        it "affiche l'encart concernant les campagnes" do
          visit admin_path
          expect(page).to have_content('Bienvenue dans votre espace conseiller !')
          expect(page).to have_content('Eva utilise le concept de "campagne" pour regrouper les ' \
                                       'passations selon leurs objectifs, leurs publics cibles ' \
                                       'ou les dispositifs mobilisés.')
          expect(page).not_to have_content('Organisez votre première session puis retrouvez ici ' \
                                           'vos dernières évaluations.')
        end
      end

      context "j'ai déjà créé une campagne mais pas d'évaluation" do
        let!(:campagne) { create :campagne, compte: compte }

        it "affiche l'encart concernant les évaluations" do
          visit admin_path
          expect(page).to have_content('Bienvenue dans votre espace conseiller !')
          expect(page).to have_content('Organisez votre première session puis retrouvez ici vos ' \
                                       'dernières évaluations.')
          expect(page).not_to have_content('Eva utilise le concept de "campagne" pour regrouper ' \
                                           'les passations selon leurs objectifs, leurs publics ' \
                                           'cibles ou les dispositifs mobilisés.')
        end
      end

      context "j'ai déjà créé une campagne et j'ai des évaluations" do
        let!(:campagne) { create :campagne, compte: compte }
        let!(:evaluation) { create :evaluation, campagne: campagne }

        it "n'affiche pas d'encart " do
          visit admin_path
          expect(page).not_to have_content('Bienvenue dans votre espace conseiller !')
          expect(page).not_to have_content('Organisez votre première session puis retrouvez ici ' \
                                           'vos dernières évaluations.')
          expect(page).not_to have_content('Eva utilise le concept de "campagne" pour regrouper ' \
                                           'les passations selon leurs objectifs, leurs publics ' \
                                           'cibles ou les dispositifs mobilisés.')
        end
      end
    end
  end
end
