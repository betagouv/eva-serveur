# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject(:ability) { Ability.new(compte) }

  let(:compte_superadmin) { create :compte_superadmin }
  let(:compte_charge_mission_regionale) do
    create :compte_charge_mission_regionale, :structure_avec_admin
  end
  let(:compte_admin) { create :compte_admin }
  let(:compte_generique) { create :compte_generique, :structure_avec_admin }
  let(:compte_conseiller) { create :compte_conseiller, :structure_avec_admin }
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
    it { is_expected.not_to be_able_to(%i[create update], Evenement.new) }
    it { is_expected.to be_able_to(:read, Evenement.new) }
    it { is_expected.to be_able_to(:manage, Situation.new) }
    it { is_expected.to be_able_to(:manage, Campagne.new) }
    it { is_expected.to be_able_to(:manage, Restitution::Base.new(nil, nil)) }
    it { is_expected.to be_able_to(:manage, Actualite) }
    it { is_expected.to be_able_to(:manage, Beneficiaire) }

    it 'avec une campagne qui a des évaluations' do
      expect(subject).not_to be_able_to(:destroy, campagne_superadmin)
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

      context "quand une campagne l'utilise" do
        let!(:campagne) { create :campagne, questionnaire: questionnaire }

        it { is_expected.not_to be_able_to(:destroy, questionnaire) }
      end

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
        let!(:questionnaire) { create :questionnaire, questions: [question] }

        it { is_expected.not_to be_able_to(:destroy, question) }
      end

      context 'quand il y a des événements réponses pour cette question' do
        before { create :evenement_reponse, donnees: { question: question.id } }

        it { is_expected.not_to be_able_to(:destroy, question) }
      end
    end

    describe 'Droits des choix' do
      let!(:choix) { create :choix, :bon }

      it { is_expected.to be_able_to(:destroy, choix) }

      context 'avec un choix présent dans un événement réponse' do
        before { create :evenement_reponse, donnees: { reponse: choix.id } }

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
    it { is_expected.not_to be_able_to(%i[create update destroy], Campagne.new) }
    it { is_expected.to be_able_to(:read, Restitution::Base.new(nil, nil)) }
    it { is_expected.to be_able_to(:read, Actualite) }
    it { is_expected.not_to be_able_to(%i[create update destroy], Actualite) }
    it { is_expected.not_to be_able_to(:read, AnnonceGenerale) }
    it { is_expected.not_to be_able_to(:read, SourceAide) }
    it { is_expected.not_to be_able_to(:read, Aide::QuestionFrequente) }
    it { is_expected.not_to be_able_to(:read, Beneficiaire) }
  end

  context 'Compte admin' do
    let(:compte) { compte_admin }

    it { is_expected.to be_able_to(:create, Compte.new) }

    context 'peut gérer mes collègues' do
      let(:mon_collegue) { create :compte, role: :conseiller, structure: compte.structure }
      let(:campagne_collegue) { create :campagne, compte: mon_collegue }
      let(:evaluation_collegue) { create :evaluation, campagne: campagne_collegue }

      it { is_expected.to be_able_to(:read, mon_collegue) }
      it { is_expected.to be_able_to(:update, mon_collegue) }
      it { is_expected.to be_able_to(:edit_role, mon_collegue) }
      it { is_expected.to be_able_to(:destroy, evaluation_collegue) }
      it { is_expected.to be_able_to(:autoriser, mon_collegue) }
      it { is_expected.to be_able_to(:refuser, mon_collegue) }

      context 'quand un compte est admin' do
        before { mon_collegue.update(role: :admin) }

        it { is_expected.not_to be_able_to(:refuser, mon_collegue) }
      end
    end

    it { is_expected.to be_able_to(:update, compte.structure) }

    context 'peut gérer les évaluations de ma structure' do
      let(:ma_campagne) { create :campagne, compte: compte }
      let(:evaluation) { create :evaluation, campagne: ma_campagne }

      it { is_expected.to be_able_to(:update, evaluation) }
    end
  end

  context 'Compte générique' do
    let(:compte) { compte_generique }

    it { is_expected.to be_able_to(:create, Compte.new) }
    it { is_expected.not_to be_able_to(:edit_role, compte) }

    context 'pour une compte de la structure' do
      let(:mon_collegue) { create :compte, structure: compte.structure }

      it { is_expected.to be_able_to(:edit_role, mon_collegue) }
    end
  end

  context 'Compte conseiller' do
    let(:compte)                    { compte_conseiller }
    let!(:campagne_conseiller)    { create :campagne, compte: compte }
    let(:evaluation_conseiller)   { create :evaluation, campagne: campagne_conseiller }
    let(:situation)                 { create :situation_inventaire }
    let!(:evenement_superadmin) { create :evenement, partie: partie_superadmin }
    let!(:partie_superadmin) do
      create :partie, evaluation: evaluation_superadmin, situation: situation
    end

    let!(:evenement_conseiller) { create :evenement, partie: partie_conseiller }
    let!(:partie_conseiller) do
      create :partie, evaluation: evaluation_conseiller, situation: situation
    end

    it 'avec une campagne qui a des évaluations' do
      expect(subject).not_to be_able_to(:destroy, campagne_conseiller)
    end

    it { is_expected.not_to be_able_to(:manage, :all) }

    it do
      expect(subject).to be_able_to(:read,
                                    ActiveAdmin::Page,
                                    name: 'Dashboard',
                                    namespace_name: 'admin')
    end

    it { is_expected.not_to be_able_to(:manage, Compte.new) }
    it { is_expected.not_to be_able_to(:manage, Structure.new) }
    it { is_expected.not_to be_able_to(%i[destroy create update], Situation.new) }
    it { is_expected.not_to be_able_to(%i[destroy create update], Question.new) }
    it { is_expected.not_to be_able_to(:manage, Questionnaire.new) }
    it { is_expected.not_to be_able_to(:manage, Campagne.new) }
    it { is_expected.not_to be_able_to(:create, evaluation_conseiller) }
    it { is_expected.not_to be_able_to(:update, evaluation_conseiller) }
    it { is_expected.not_to be_able_to(%i[read destroy], evaluation_superadmin) }
    it { is_expected.not_to be_able_to(:read, Evenement.new) }
    it { is_expected.not_to be_able_to(:read, evenement_superadmin) }
    it { is_expected.not_to be_able_to(:read, SourceAide.new) }
    it { is_expected.not_to be_able_to(:read, Aide::QuestionFrequente.new) }
    it { is_expected.not_to be_able_to(:update, compte.structure) }
    it { is_expected.to be_able_to(:create, Campagne.new) }
    it { is_expected.to be_able_to(:update, compte) }
    it { is_expected.not_to be_able_to(:update, create(:compte)) }
    it { is_expected.to be_able_to(:read, Question.new) }
    it { is_expected.to be_able_to(%i[read destroy], evaluation_conseiller) }
    it { is_expected.to be_able_to(:read, evenement_conseiller) }
    it { is_expected.to be_able_to(%i[update read], Campagne.new(compte: compte)) }
    it { is_expected.to be_able_to(:destroy, Campagne.new(compte: compte)) }
    it { is_expected.to be_able_to(:read, Questionnaire.new) }
    it { is_expected.to be_able_to(:read, Situation.new) }
    it { is_expected.to be_able_to(:manage, Restitution::Base.new(campagne_conseiller, nil)) }
    it { is_expected.to be_able_to(:read, Actualite.new) }
    it { is_expected.to be_able_to(:read, ActiveAdmin::Page.new(1, 2, 3)) }

    context 'peut consulter les campagnes de ma structure' do
      let(:mon_collegue) { create :compte, structure: compte_conseiller.structure }
      let(:campagne_collegue) { create :campagne, compte: mon_collegue }
      let(:evaluation_collegue) { create :evaluation, campagne: campagne_collegue }
      let!(:partie_collegue) do
        create :partie, evaluation: evaluation_collegue, situation: situation
      end
      let(:evenement_collegue) { create :evenement, partie: partie_collegue }

      it { is_expected.to be_able_to(:read, campagne_collegue) }
      it { is_expected.to be_able_to(:read, evaluation_collegue) }
      it { is_expected.not_to be_able_to(:destroy, evaluation_collegue) }
      it { is_expected.to be_able_to(:manage, Restitution::Base.new(campagne_collegue, nil)) }
      it { is_expected.to be_able_to(:read, evenement_collegue) }
      it { is_expected.to be_able_to(:read, mon_collegue) }
    end

    context 'pour un compte en attente' do
      let(:mon_collegue) do
        create :compte_conseiller, :en_attente, structure: compte_conseiller.structure
      end

      it { is_expected.to be_able_to(:autoriser, mon_collegue) }
      it { is_expected.to be_able_to(:refuser, mon_collegue) }
    end

    context 'pour un compte refusé' do
      let(:mon_collegue) do
        create :compte_conseiller, :refusee, structure: compte_conseiller.structure
      end

      it { is_expected.not_to be_able_to(:autoriser, mon_collegue) }
      it { is_expected.not_to be_able_to(:refuser, mon_collegue) }
    end

    context 'pour un compte accepté' do
      let(:mon_collegue) do
        create :compte_conseiller, :acceptee, structure: compte_conseiller.structure
      end

      it { is_expected.not_to be_able_to(:autoriser, mon_collegue) }
      it { is_expected.not_to be_able_to(:refuser, mon_collegue) }
    end
  end

  context 'Compte en attente de validation' do
    let!(:compte) { create :compte_conseiller, :structure_avec_admin, :en_attente }
    let!(:ma_campagne) { create :campagne, compte: compte }
    let!(:mon_evaluation) { create :evaluation, campagne: ma_campagne }

    let!(:autre_compte) { create :compte_conseiller, structure: compte.structure }
    let!(:autre_campagne) { create :campagne, compte: autre_compte }
    let!(:autre_evaluation) { create :evaluation, campagne: autre_campagne }

    it 'peut créer une campagne' do
      expect(subject).to be_able_to(:create, Campagne.new)
    end

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
    let!(:compte) { create :compte_conseiller, :structure_avec_admin, :refusee }

    it 'peut consulter et modifier son compte' do
      expect(subject).to be_able_to(:read, compte)
      expect(subject).to be_able_to(:update, compte)
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
end
