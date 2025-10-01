# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject(:ability) { described_class.new(compte) }

  let(:compte_superadmin) { create :compte_superadmin }
  let(:structure_avec_admin) { create :structure, :avec_admin }
  let(:compte_charge_mission_regionale) do
    create :compte_charge_mission_regionale, structure: structure_avec_admin
  end
  let(:compte_conseiller) { create :compte_conseiller, structure: structure_avec_admin }
  let!(:campagne_superadmin) { create :campagne, compte: compte_superadmin }
  let!(:campagne_superadmin_sans_eval) { create :campagne, compte: compte_superadmin }
  let!(:campagne_conseiller) { create :campagne, compte: compte_conseiller }

  let!(:evaluation_superadmin) { create :evaluation, campagne: campagne_superadmin }
  let(:situation) { create :situation_inventaire }
  let(:situation_non_utilisee) { create :situation_controle }

  before { campagne_superadmin.situations_configurations.create situation: situation }

  context 'Compte superadmin' do
    let(:compte) { compte_superadmin }

    it { is_expected.to be_able_to(:manage, :all) }

    it do
      expect(subject).to be_able_to(:read,
                                    ActiveAdmin::Page,
                                    name: 'Dashboard',
                                    namespace_name: 'admin')
    end

    it { is_expected.to be_able_to(%i[read destroy update], Evaluation.new) }
    it { is_expected.not_to be_able_to(%i[create], Evaluation.new) }
    it { is_expected.to be_able_to(:destroy, Beneficiaire.new) }
    it { is_expected.not_to be_able_to(:destroy, evaluation_superadmin.beneficiaire) }
    it { is_expected.not_to be_able_to(%i[create update destroy], Evenement.new) }
    it { is_expected.to be_able_to(:read, Evenement.new) }
    it { is_expected.to be_able_to(:manage, Situation.new) }
    it { is_expected.to be_able_to(:manage, Campagne.new) }
    it { is_expected.to be_able_to(:manage, Restitution::Base.new(nil, nil)) }
    it { is_expected.to be_able_to(:manage, Actualite) }
    it { is_expected.to be_able_to(:manage, Beneficiaire) }

    it 'avec une campagne qui a des évaluations' do
      expect(subject).to be_able_to(:destroy, campagne_superadmin)
    end

    it "avec une campagne qui n'a pas d'évaluation" do
      expect(subject).to be_able_to(:destroy, campagne_superadmin_sans_eval)
    end

    it 'avec un compte qui est lié à une campagne' do
      expect(subject).not_to be_able_to(:destroy, compte_conseiller)
    end

    it 'avec une situation utilisé dans une campagne' do
      expect(subject).not_to be_able_to(:destroy, situation)
    end

    it 'avec une situation non utilisé dans des campagne' do
      expect(subject).to be_able_to(:destroy, situation_non_utilisee)
    end

    describe 'Droits des questionnaires' do
      let(:questionnaire) { create :questionnaire }

      it { is_expected.to be_able_to(:manage, Questionnaire.new) }

      context "quand une situation l'utilise comme questionnaire principal" do
        let!(:situation) { create :situation_livraison, questionnaire: questionnaire }

        it { is_expected.not_to be_able_to(:destroy, questionnaire) }
      end

      context "quand une situation l'utilise comme questionnaire d'entrainement" do
        let!(:situation) { create :situation_livraison, questionnaire_entrainement: questionnaire }

        it { is_expected.not_to be_able_to(:destroy, questionnaire) }
      end
    end

    describe 'Droits des questions' do
      let(:question) { create(:question) }

      it { is_expected.to be_able_to(:manage, Question.new) }

      context "quand un questionnaire l'utilise" do
        let!(:questionnaire) { create :questionnaire, questions: [ question ] }

        it { is_expected.not_to be_able_to(:destroy, question) }
      end

      context 'quand la question existe depuis plus un mois' do
        # cette question est peut-être utilisé dans un événement
        # mais faire la requette sur la table evenements coute trop cher
        let(:question) do
          Timecop.freeze(1.month.ago) { create(:question) }
        end

        it { is_expected.not_to be_able_to(:destroy, question) }
      end
    end

    describe 'Droits des choix' do
      let!(:choix) { create :choix, :bon }

      it { is_expected.to be_able_to(:destroy, choix) }

      context "avec un choix qui existe depuis plus d'un mois" do
        # ce choix  est peut-être utilisé dans un événement comme réponse
        # mais faire la requette sur la table evenements coute trop cher
        let!(:choix) do
          Timecop.freeze(1.month.ago) { create :choix, :bon }
        end

        it { is_expected.not_to be_able_to(:destroy, choix) }
      end
    end

    describe 'Droits des structures' do
      let!(:structure) { create :structure_locale }

      it { is_expected.to be_able_to(:destroy, structure) }

      context 'avec un compte rattaché' do
        let!(:compte) { create :compte, structure: structure }

        it { is_expected.not_to be_able_to(:destroy, structure) }
      end
    end
  end

  context 'Compte CMR' do
    let(:compte) { compte_charge_mission_regionale }

    it { is_expected.to be_able_to(:read, :all) }

    it do
      expect(subject).to be_able_to(:read,
                                    ActiveAdmin::Page,
                                    name: 'Dashboard',
                                    namespace_name: 'admin')
    end

    it { is_expected.to be_able_to(%i[read], Evaluation.new) }
    it { is_expected.not_to be_able_to(%i[create update destroy], Evaluation.new) }
    it { is_expected.to be_able_to(:read, Evenement.new) }
    it { is_expected.not_to be_able_to(%i[create update destroy], Evenement.new) }
    it { is_expected.to be_able_to(:read, Situation.new) }
    it { is_expected.not_to be_able_to(%i[create update destroy], Situation.new) }
    it { is_expected.to be_able_to(:read, Campagne.new) }
    it { is_expected.not_to be_able_to(%i[create duplique update destroy], Campagne.new) }
    it { is_expected.not_to be_able_to(%i[autoriser_compte revoquer_compte], Campagne) }
    it { is_expected.to be_able_to(:read, Restitution::Base.new(nil, nil)) }
    it { is_expected.to be_able_to(:read, Actualite) }
    it { is_expected.not_to be_able_to(%i[create update destroy], Actualite) }
    it { is_expected.not_to be_able_to(:read, AnnonceGenerale) }
    it { is_expected.not_to be_able_to(:read, SourceAide) }
    it { is_expected.to be_able_to(:read, Beneficiaire) }
    it { is_expected.not_to be_able_to(:fusionner, Beneficiaire) }
    it { is_expected.not_to be_able_to(:supprimer_responsable_suivi, Evaluation) }
    it { is_expected.not_to be_able_to(:renseigner_qualification, Evaluation) }
    it { is_expected.not_to be_able_to(:ajouter_responsable_suivi, Evaluation) }
  end

  context 'Compte admin' do
    let(:compte) { create :compte_admin }

    it { is_expected.to be_able_to(:create, Compte.new) }
    it { is_expected.to be_able_to(:create, Beneficiaire) }
    it { is_expected.to be_able_to(:update, compte.structure) }

    context 'peut gérer mes collègues' do
      let(:mon_collegue) { create :compte, role: :conseiller, structure: compte.structure }
      let(:pas_collegue) { compte_conseiller }
      let(:campagne_collegue) { create :campagne, compte: mon_collegue, privee: true }
      let(:evaluation_collegue) { create :evaluation, campagne: campagne_collegue }

      it { is_expected.to be_able_to(:read, mon_collegue) }
      it { is_expected.to be_able_to(:update, mon_collegue) }
      it { is_expected.to be_able_to(:edit_role, mon_collegue) }
      it { is_expected.to be_able_to(:destroy, evaluation_collegue) }
      it { is_expected.to be_able_to(:read, campagne_collegue) }
      it { is_expected.to be_able_to(:autoriser, mon_collegue) }
      it { is_expected.to be_able_to(:refuser, mon_collegue) }
      it { is_expected.to be_able_to(:verifier, mon_collegue) }
      it { is_expected.to be_able_to(:destroy, mon_collegue) }
      it { is_expected.not_to be_able_to(:destroy, pas_collegue) }

      context 'quand un collegue est admin' do
        before { mon_collegue.update(role: :admin) }

        it { is_expected.not_to be_able_to(:refuser, mon_collegue) }
        it { is_expected.not_to be_able_to(:destroy, mon_collegue) }
      end
    end

    context 'peut gérer les évaluations de ma structure' do
      let(:ma_campagne) { create :campagne, compte: compte }
      let(:evaluation) { create :evaluation, campagne: ma_campagne }
      let(:beneficiaire_vide) { create :beneficiaire }

      it { is_expected.to be_able_to(:update, evaluation) }
      it { is_expected.to be_able_to(:fusionner, Beneficiaire) }
      it { is_expected.to be_able_to(:supprimer_responsable_suivi, evaluation) }
      it { is_expected.to be_able_to(:ajouter_responsable_suivi, evaluation) }
      it { is_expected.to be_able_to(:renseigner_qualification, evaluation) }
      it { is_expected.to be_able_to(%i[read update], evaluation.beneficiaire) }
      it { is_expected.to be_able_to(:destroy, beneficiaire_vide) }
      it { is_expected.not_to be_able_to(:destroy, evaluation.beneficiaire) }
    end
  end

  context 'Compte générique' do
    let(:compte) { create :compte_generique, structure: structure_avec_admin }

    it { is_expected.to be_able_to(:create, Compte.new) }
    it { is_expected.not_to be_able_to(:edit_role, compte) }

    context 'pour une compte de la structure' do
      let(:mon_collegue) { create :compte, structure: compte.structure }

      it { is_expected.to be_able_to(:edit_role, mon_collegue) }
    end
  end

  context 'Compte conseiller sans structure' do
    let(:compte) { create :compte_conseiller, :en_attente, structure: nil }

    it {
      expect(subject).to be_able_to(:read, ActiveAdmin::Page.new(:admin, 'recherche_structure', {}))
    }

    it { is_expected.to be_able_to(:create, StructureLocale.new) }
  end

  context 'Compte conseiller' do
    let(:compte) { compte_conseiller }
    let(:mon_collegue) { create :compte_conseiller, structure: structure_avec_admin }
    let!(:campagne_privee) { create :campagne, compte: compte, privee: true }
    let!(:campagne_collegue) { create :campagne, compte: mon_collegue, privee: true }
    let(:evaluation_conseiller) { create :evaluation, campagne: campagne_privee }
    let(:evaluation_autre_conseiller) { create :evaluation, campagne: campagne_collegue }
    let(:situation)             { create :situation_inventaire }
    let!(:evenement_superadmin) { create :evenement, partie: partie_superadmin }
    let!(:partie_superadmin) do
      create :partie, evaluation: evaluation_superadmin, situation: situation
    end

    let!(:partie_conseiller) do
      create :partie, evaluation: evaluation_conseiller, situation: situation
    end


    it 'avec une campagne qui a des évaluations' do
      expect(subject).to be_able_to(:destroy, campagne_privee)
    end

    it { is_expected.not_to be_able_to(:manage, :all) }

    it do
      expect(subject).to be_able_to(:read,
      ActiveAdmin::Page,
      name: 'Dashboard',
      namespace_name: 'admin')
    end

    it { is_expected.not_to be_able_to(:destroy, Beneficiaire) }
    it { is_expected.not_to be_able_to(:manage, Compte.new) }
    it { is_expected.not_to be_able_to(:manage, Structure.new) }
    it { is_expected.not_to be_able_to(%i[destroy create update], Situation.new) }
    it { is_expected.not_to be_able_to(%i[destroy create update], Question.new) }
    it { is_expected.not_to be_able_to(:manage, Questionnaire.new) }
    it { is_expected.not_to be_able_to(:manage, Campagne.new) }
    it { is_expected.not_to be_able_to(:create, evaluation_conseiller) }
    it { is_expected.not_to be_able_to(:update, evaluation_conseiller) }
    it { is_expected.to be_able_to(:supprimer_responsable_suivi, evaluation_conseiller) }
    it { is_expected.to be_able_to(:ajouter_responsable_suivi, evaluation_conseiller) }
    it { is_expected.not_to be_able_to(%i[read destroy], evaluation_superadmin) }
    it { is_expected.not_to be_able_to(%i[read], campagne_collegue) }
    it { is_expected.not_to be_able_to(:read, Evenement.new) }
    it { is_expected.not_to be_able_to(:read, evenement_superadmin) }
    it { is_expected.not_to be_able_to(:read, SourceAide.new) }
    it { is_expected.not_to be_able_to(:update, compte.structure) }
    it { is_expected.to be_able_to(:update, compte) }
    it { is_expected.not_to be_able_to(:update, create(:compte)) }
    it { is_expected.to be_able_to(:read, Question.new) }
    it { is_expected.to be_able_to(%i[read mise_en_action destroy], evaluation_conseiller) }
    it { is_expected.to be_able_to(%i[read], evaluation_conseiller.beneficiaire) }

    it do
      expect(subject).to be_able_to(%i[read update autoriser_compte revoquer_compte destroy],
                                    Campagne.new(compte: compte))
    end

    it { is_expected.not_to be_able_to(:destroy, campagne_superadmin) }
    it { is_expected.to be_able_to(:read, Questionnaire.new) }
    it { is_expected.to be_able_to(:read, Situation.new) }
    it { is_expected.to be_able_to(:manage, Restitution::Base.new(campagne_privee, nil)) }
    it { is_expected.to be_able_to(:read, Actualite.new) }
    it { is_expected.to be_able_to(:read, ActiveAdmin::Page.new(:admin, 'Aide', {})) }
    it { is_expected.to be_able_to(:read, ActiveAdmin::Page.new(:admin, 'Dashboard', {})) }

    it {
      expect(subject).not_to be_able_to(:read,
                                        ActiveAdmin::Page.new(:admin, 'recherche_structure', {}))
    }

    context "quand la structure n'autorise pas la création de campagne" do
      before do
        compte.structure.update(autorisation_creation_campagne: false)
      end

      it { is_expected.not_to be_able_to(:create, Campagne) }
      it { is_expected.not_to be_able_to(:duplique, Campagne) }
    end

    context "quand la structure autorise la création de campagne" do
      before do
        compte.structure.update(autorisation_creation_campagne: true)
      end

      it { is_expected.to be_able_to(:create, Campagne) }
      it { is_expected.to be_able_to(:duplique, Campagne) }
    end

    context "quand j'ai accès à la campagne privé d'un autre conseiller" do
      before do
        campagne_collegue.campagne_compte_autorisations.create!(compte_id: compte.id)
      end

      it { is_expected.to be_able_to(:read, campagne_collegue) }
      it { is_expected.to be_able_to(:read, evaluation_autre_conseiller) }
      it { is_expected.to be_able_to(:read, evaluation_autre_conseiller.beneficiaire) }
    end

    context "quand je n'ai pas accès à la campagne privé d'un autre conseiller" do
      it { is_expected.not_to be_able_to(:read, campagne_collegue) }
      it { is_expected.not_to be_able_to(:read, evaluation_autre_conseiller) }
      it { is_expected.not_to be_able_to(:read, evaluation_autre_conseiller.beneficiaire) }
    end

    context 'peut consulter les campagnes publiques de ma structure' do
      let(:evaluation_collegue) { create :evaluation, campagne: campagne_collegue }
      let!(:partie_collegue) do
        create :partie, evaluation: evaluation_collegue, situation: situation
      end

      before do
        campagne_collegue.update(privee: false)
      end

      it { is_expected.to be_able_to(:read, evaluation_collegue) }
      it { is_expected.to be_able_to(:read, evaluation_collegue.beneficiaire) }
      it { is_expected.not_to be_able_to(:destroy, evaluation_collegue) }
      it { is_expected.to be_able_to(:manage, Restitution::Base.new(campagne_collegue, nil)) }
      it { is_expected.to be_able_to(:read, mon_collegue) }
      it { is_expected.to be_able_to(:read, campagne_collegue) }
      it { is_expected.not_to be_able_to(%i[update destroy], campagne_collegue) }
      it { is_expected.not_to be_able_to(%i[autoriser_compte revoquer_compte], campagne_collegue) }
    end

    context 'pour un compte en attente' do
      let(:mon_collegue) do
        create :compte_conseiller, :en_attente, structure: compte_conseiller.structure
      end

      it { is_expected.not_to be_able_to(:verifier, mon_collegue) }
      it { is_expected.not_to be_able_to(:autoriser, mon_collegue) }
      it { is_expected.not_to be_able_to(:refuser, mon_collegue) }
    end

    context 'pour un compte refusé' do
      let(:mon_collegue) do
        create :compte_conseiller, :refusee, structure: compte_conseiller.structure
      end

      it { is_expected.not_to be_able_to(:verifier, mon_collegue) }
      it { is_expected.not_to be_able_to(:autoriser, mon_collegue) }
      it { is_expected.not_to be_able_to(:refuser, mon_collegue) }
    end

    context 'pour un compte accepté' do
      let(:mon_collegue) do
        create :compte_conseiller, :acceptee, structure: compte_conseiller.structure
      end

      it { is_expected.not_to be_able_to(:verifier, mon_collegue) }
      it { is_expected.not_to be_able_to(:autoriser, mon_collegue) }
      it { is_expected.not_to be_able_to(:refuser, mon_collegue) }
    end
  end

  context 'Compte en attente de validation' do
    let!(:compte) { create :compte_conseiller, :en_attente, structure: structure_avec_admin }
    let!(:ma_campagne) { create :campagne, compte: compte }
    let!(:mon_evaluation) { create :evaluation, campagne: ma_campagne }

    let!(:autre_compte) { create :compte_conseiller, structure: compte.structure }
    let!(:autre_campagne) { create :campagne, compte: autre_compte }
    let!(:autre_evaluation) { create :evaluation, campagne: autre_campagne }

    it 'peut lire ses campagnes' do
      expect(subject).to be_able_to(:read, ma_campagne)
    end

    it 'peut consulter son compte' do
      expect(subject).to be_able_to(:read, compte)
    end

    it 'ne peut pas consulter ses collègues' do
      expect(subject).not_to be_able_to(:read, autre_compte)
      expect(subject).not_to be_able_to(:update, autre_compte)
    end

    it 'ne peut pas accéder aux campagnes de ses collègues' do
      expect(subject).not_to be_able_to(:read, autre_campagne)
      expect(subject).not_to be_able_to(:destroy, autre_campagne)
    end

    it 'ne peut pas accéder aux évaluations de ses collègues ni les supprimer' do
      expect(subject).not_to be_able_to(:read, autre_evaluation)
      expect(subject).not_to be_able_to(:destroy, autre_evaluation)
    end

    it 'ne peut pas consulter la page de la structure' do
      expect(subject).not_to be_able_to(:read, compte.structure)
    end
  end

  context 'Compte refusé' do
    let!(:compte) { create :compte_conseiller, :refusee, structure: structure_avec_admin }

    it 'peut consulter et modifier son compte' do
      expect(subject).to be_able_to(:read, compte)
      expect(subject).to be_able_to(:update, compte)
      expect(subject).to be_able_to(:accepter_cgu, compte)
    end

    it 'ne peut pas consulter les Campagnes' do
      expect(subject).not_to be_able_to(:read, Campagne)
    end

    it 'ne peut pas consulter les Actualités' do
      expect(subject).not_to be_able_to(:read, Actualite)
    end

    it 'ne peut pas consulter les Evaluations' do
      expect(subject).not_to be_able_to(:read, Evaluation)
    end
  end

  context 'Compte de démo' do
    let!(:compte) { create :compte_conseiller, :structure_avec_admin, email: Eva::EMAIL_DEMO }

    it 'ne peut pas modifier son compte' do
      expect(subject).to be_able_to(:read, compte)
      expect(subject).not_to be_able_to(:update, compte)
    end
  end
end
