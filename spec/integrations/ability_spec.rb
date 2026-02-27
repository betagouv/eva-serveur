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

    it do
      expect(subject).to be_able_to(:manage, :all)
      expect(subject).to be_able_to(:read,
                                    ActiveAdmin::Page,
                                    name: 'Dashboard',
                                    namespace_name: 'admin')
      expect(subject).to be_able_to(%i[read destroy update], Evaluation.new)
      expect(subject).not_to be_able_to(%i[create], Evaluation.new)
      expect(subject).to be_able_to(:destroy, Beneficiaire.new)
      expect(subject).not_to be_able_to(:destroy, evaluation_superadmin.beneficiaire)
      expect(subject).not_to be_able_to(%i[create update destroy], Evenement.new)
      expect(subject).to be_able_to(:read, Evenement.new)
      expect(subject).to be_able_to(:manage, Situation.new)
      expect(subject).to be_able_to(:manage, Campagne.new)
      expect(subject).to be_able_to(:manage, Restitution::Base.new(nil, nil))
      expect(subject).to be_able_to(:manage, Actualite)
      expect(subject).to be_able_to(:manage, Beneficiaire)
      expect(subject).to be_able_to(:destroy, campagne_superadmin)
      expect(subject).to be_able_to(:destroy, campagne_superadmin_sans_eval)
      expect(subject).not_to be_able_to(:destroy, compte_conseiller)
      expect(subject).not_to be_able_to(:destroy, situation)
      expect(subject).to be_able_to(:destroy, situation_non_utilisee)
    end

    describe 'Droits des questionnaires' do
      let(:questionnaire) { create :questionnaire }

      it { expect(subject).to be_able_to(:manage, Questionnaire.new) }

      context "quand une situation l'utilise comme questionnaire principal" do
        let!(:situation) { create :situation_livraison, questionnaire: questionnaire }

        it { expect(subject).not_to be_able_to(:destroy, questionnaire) }
      end

      context "quand une situation l'utilise comme questionnaire d'entrainement" do
        let!(:situation) { create :situation_livraison, questionnaire_entrainement: questionnaire }

        it { expect(subject).not_to be_able_to(:destroy, questionnaire) }
      end
    end

    describe 'Droits des questions' do
      let(:question) { create(:question) }

      it { expect(subject).to be_able_to(:manage, Question.new) }

      context "quand un questionnaire l'utilise" do
        let!(:questionnaire) { create :questionnaire, questions: [ question ] }

        it { expect(subject).not_to be_able_to(:destroy, question) }
      end

      context 'quand la question existe depuis plus un mois' do
        # cette question est peut-être utilisé dans un événement
        # mais faire la requette sur la table evenements coute trop cher
        let(:question) do
          Timecop.freeze(1.month.ago) { create(:question) }
        end

        it { expect(subject).not_to be_able_to(:destroy, question) }
      end
    end

    describe 'Droits des choix' do
      let!(:choix) { create :choix, :bon }

      it { expect(subject).to be_able_to(:destroy, choix) }

      context "avec un choix qui existe depuis plus d'un mois" do
        # ce choix  est peut-être utilisé dans un événement comme réponse
        # mais faire la requette sur la table evenements coute trop cher
        let!(:choix) do
          Timecop.freeze(1.month.ago) { create :choix, :bon }
        end

        it { expect(subject).not_to be_able_to(:destroy, choix) }
      end
    end

    describe 'Droits des structures' do
      let!(:structure) { create :structure_locale }

      it { expect(subject).to be_able_to(:destroy, structure) }
      it { expect(subject).to be_able_to(:envoyer_invitation, structure) }

      context 'avec un compte rattaché' do
        let!(:compte) { create :compte, structure: structure }

        it { expect(subject).not_to be_able_to(:destroy, structure) }
      end
    end
  end

  context 'Compte CMR' do
    let(:compte) { compte_charge_mission_regionale }

    it do
      expect(subject).to be_able_to(:read, :all)
      expect(subject).to be_able_to(:read,
                                    ActiveAdmin::Page,
                                    name: 'Dashboard',
                                    namespace_name: 'admin')
      expect(subject).to be_able_to(%i[read], Evaluation.new)
      expect(subject).not_to be_able_to(%i[create update destroy], Evaluation.new)
      expect(subject).to be_able_to(:read, Evenement.new)
      expect(subject).not_to be_able_to(%i[create update destroy], Evenement.new)
      expect(subject).to be_able_to(:read, Situation.new)
      expect(subject).not_to be_able_to(%i[create update destroy], Situation.new)
      expect(subject).to be_able_to(:read, Campagne.new)
      expect(subject).not_to be_able_to(%i[create duplique update destroy], Campagne.new)
      expect(subject).not_to be_able_to(%i[autoriser_compte revoquer_compte], Campagne)
      expect(subject).to be_able_to(:read, Restitution::Base.new(nil, nil))
      expect(subject).to be_able_to(:read, Actualite)
      expect(subject).not_to be_able_to(%i[create update destroy], Actualite)
      expect(subject).not_to be_able_to(:read, AnnonceGenerale)
      expect(subject).not_to be_able_to(:read, SourceAide)
      expect(subject).to be_able_to(:read, Beneficiaire)
      expect(subject).not_to be_able_to(:fusionner, Beneficiaire)
      expect(subject).not_to be_able_to(:supprimer_responsable_suivi, Evaluation)
      expect(subject).not_to be_able_to(:renseigner_qualification, Evaluation)
      expect(subject).not_to be_able_to(:ajouter_responsable_suivi, Evaluation)
    end
  end

  context 'Compte admin' do
    let(:compte) { create :compte_admin }

    it do
      expect(subject).to be_able_to(:create, Compte.new)
      expect(subject).not_to be_able_to(:create, Beneficiaire)
      expect(subject).to be_able_to(:update, compte.structure)
    end

    context 'peut gérer mes collègues' do
      let(:mon_collegue) { create :compte, role: :conseiller, structure: compte.structure }
      let(:pas_collegue) { compte_conseiller }
      let(:campagne_collegue) { create :campagne, compte: mon_collegue, privee: true }
      let(:evaluation_collegue) { create :evaluation, campagne: campagne_collegue }

      it do
        expect(subject).to be_able_to(:read, mon_collegue)
        expect(subject).to be_able_to(:update, mon_collegue)
        expect(subject).to be_able_to(:edit_role, mon_collegue)
        expect(subject).to be_able_to(:destroy, evaluation_collegue)
        expect(subject).to be_able_to(:read, campagne_collegue)
        expect(subject).to be_able_to(:autoriser, mon_collegue)
        expect(subject).to be_able_to(:refuser, mon_collegue)
        expect(subject).to be_able_to(:verifier, mon_collegue)
        expect(subject).not_to be_able_to(:destroy, mon_collegue)
        expect(subject).not_to be_able_to(:destroy, pas_collegue)
      end

      context 'quand un collegue est admin' do
        before { mon_collegue.update(role: :admin) }

        it do
          expect(subject).not_to be_able_to(:refuser, mon_collegue)
          expect(subject).not_to be_able_to(:destroy, mon_collegue)
        end
      end
    end

    context 'peut gérer les comptes des sous-structures' do
      let(:structure_fille) {
        create :structure_locale, :avec_admin, structure_referente: compte.structure }
      let(:compte_sous_structure) { create :compte, role: :conseiller, structure: structure_fille }
      let(:campagne_sous_structure) {
        create :campagne, compte: compte_sous_structure, privee: true }
      let(:evaluation_sous_structure) { create :evaluation, campagne: campagne_sous_structure }

      before do
        # Force la création de la structure fille
        structure_fille
      end

      it do
        expect(subject).to be_able_to(:read, compte_sous_structure)
        expect(subject).to be_able_to(:update, compte_sous_structure)
        expect(subject).to be_able_to(:edit_role, compte_sous_structure)
        expect(subject).to be_able_to(:read, campagne_sous_structure)
        expect(subject).to be_able_to(:update, campagne_sous_structure)
        expect(subject).to be_able_to(:destroy, evaluation_sous_structure)
        expect(subject).to be_able_to(:autoriser, compte_sous_structure)
        expect(subject).to be_able_to(:refuser, compte_sous_structure)
        expect(subject).to be_able_to(:verifier, compte_sous_structure)
      end
    end

    context 'peut voir et modifier les structures filles' do
      let(:structure_fille) {
        create :structure_locale, :avec_admin, structure_referente: compte.structure }

      before do
        # Force la création de la structure fille
        structure_fille
      end

      it do
        expect(subject).to be_able_to(:read, structure_fille)
        expect(subject).to be_able_to(:update, structure_fille)
      end

      it 'peut envoyer une invitation pour sa structure et pour les structures filles' do
        expect(subject).to be_able_to(:envoyer_invitation, compte.structure)
        expect(subject).to be_able_to(:envoyer_invitation, structure_fille)
      end
    end

    context 'peut gérer les évaluations de ma structure' do
      let(:ma_campagne) { create :campagne, compte: compte }
      let(:evaluation) { create :evaluation, campagne: ma_campagne }
      let(:beneficiaire_vide) { create :beneficiaire }

      it do
        expect(subject).to be_able_to(:update, evaluation)
        expect(subject).to be_able_to(:fusionner, Beneficiaire)
        expect(subject).to be_able_to(:supprimer_responsable_suivi, evaluation)
        expect(subject).to be_able_to(:ajouter_responsable_suivi, evaluation)
        expect(subject).to be_able_to(:mise_en_action, evaluation)
        expect(subject).to be_able_to(:renseigner_qualification, evaluation)
        expect(subject).to be_able_to(%i[read update], evaluation.beneficiaire)
        expect(subject).to be_able_to(:destroy, beneficiaire_vide)
        expect(subject).not_to be_able_to(:destroy, evaluation.beneficiaire)
      end
    end

    context 'peut gérer les mise en actions des campagnes privés des collègues' do
      let(:mon_collegue) { create :compte, role: :conseiller, structure: compte.structure }
      let(:campagne_collegue) { create :campagne, compte: mon_collegue, privee: true }
      let(:evaluation_collegue) { create :evaluation, campagne: campagne_collegue }

      it do
        expect(subject).to be_able_to(:mise_en_action, evaluation_collegue)
        expect(subject).to be_able_to(:renseigner_qualification, evaluation_collegue)
      end
    end
  end

  context 'Compte admin de structure administrative' do
    let(:structure_administrative) { create :structure_administrative }
    let(:compte) { create :compte_admin, structure: structure_administrative }
    let(:beneficiaire) { create :beneficiaire }

    it 'ne peut pas créer de compte' do
      expect(subject).not_to be_able_to(:create, Compte.new)
    end

    it 'ne peut pas créer de bénéficiaire' do
      expect(subject).not_to be_able_to(:create, Beneficiaire.new)
    end

    it 'ne peut pas modifier de bénéficiaire' do
      expect(subject).not_to be_able_to(:update, beneficiaire)
    end

    it 'peut fusionner de bénéficiaire' do
      expect(subject).to be_able_to(:fusionner, beneficiaire)
    end

    it 'ne peut pas supprimer de bénéficiaire' do
      expect(subject).not_to be_able_to(:destroy, beneficiaire)
    end

    it 'peut créer une campagne' do
      expect(subject).to be_able_to(:create, Campagne.new)
    end

    it 'ne peut pas dupliquer de campagne' do
      expect(subject).not_to be_able_to(:duplique, Campagne.new)
    end

    context "avec des structures filles" do
      let!(:structure_locale_fille) do
        create :structure_locale, structure_referente: structure_administrative
      end
      let!(:compte_structure_fille) { create :compte_admin, structure: structure_locale_fille }
      let!(:campagne_structure_fille) { create :campagne, compte: compte_structure_fille }
      let!(:evaluation_structure_fille) { create :evaluation, campagne: campagne_structure_fille }

      it 'peut voir les bénéficiaires des campagnes des structures filles' do
        expect(subject).to be_able_to(:read, evaluation_structure_fille.beneficiaire)
      end

      it 'peut faire des mises en action sur les évaluations des structures filles' do
        expect(subject).to be_able_to(:mise_en_action, evaluation_structure_fille)
        expect(subject).to be_able_to(:renseigner_qualification, evaluation_structure_fille)
      end
    end
  end

  context 'Compte générique' do
    let(:compte) { create :compte_generique, structure: structure_avec_admin }

    it do
      expect(subject).to be_able_to(:create, Compte.new)
      expect(subject).not_to be_able_to(:edit_role, compte)
    end

    context 'pour une compte de la structure' do
      let(:mon_collegue) { create :compte, structure: compte.structure }

      it do
        expect(subject).to be_able_to(:edit_role, mon_collegue)
      end
    end
  end

  context 'Compte conseiller sans structure' do
    let(:compte) { create :compte_conseiller, :en_attente, structure: nil }

    it do
      expect(subject).to be_able_to(:read, ActiveAdmin::Page.new(:admin, 'recherche_structure', {}))
      expect(subject).to be_able_to(:create, StructureLocale.new)
    end
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

    it do
      expect(subject).not_to be_able_to(:destroy, Beneficiaire)
      expect(subject).to be_able_to(:destroy, campagne_privee)
      expect(subject).not_to be_able_to(:manage, :all)
      expect(subject).to be_able_to(:read,
                                    ActiveAdmin::Page,
                                    name: 'Dashboard',
                                    namespace_name: 'admin')
      expect(subject).to be_able_to(:read,
                                    ActiveAdmin::Page,
                                    name: 'Comparaison')
      expect(subject).to be_able_to(:download_pdf,
                                    ActiveAdmin::Page,
                                    name: 'Comparaison')
      expect(subject).not_to be_able_to(:manage, Compte.new)
      expect(subject).not_to be_able_to(:manage, Structure.new)
      expect(subject).not_to be_able_to(%i[destroy create update], Situation.new)
      expect(subject).not_to be_able_to(%i[destroy create update], Question.new)
      expect(subject).not_to be_able_to(:manage, Questionnaire.new)
      expect(subject).not_to be_able_to(:manage, Campagne.new)
      expect(subject).not_to be_able_to(:create, evaluation_conseiller)
      expect(subject).not_to be_able_to(:update, evaluation_conseiller)
      expect(subject).to be_able_to(:supprimer_responsable_suivi, evaluation_conseiller)
      expect(subject).to be_able_to(:ajouter_responsable_suivi, evaluation_conseiller)
      expect(subject).not_to be_able_to(%i[read destroy], evaluation_superadmin)
      expect(subject).not_to be_able_to(%i[read], campagne_collegue)
      expect(subject).not_to be_able_to(:read, Evenement.new)
      expect(subject).not_to be_able_to(:read, evenement_superadmin)
      expect(subject).not_to be_able_to(:read, SourceAide.new)
      expect(subject).not_to be_able_to(:update, compte.structure)
      expect(subject).to be_able_to(:update, compte)
      expect(subject).not_to be_able_to(:update, create(:compte))
      expect(subject).to be_able_to(:read, Question.new)
      expect(subject).to be_able_to(%i[read mise_en_action destroy], evaluation_conseiller)
      expect(subject).to be_able_to(%i[read], evaluation_conseiller.beneficiaire)
      expect(subject).to be_able_to(%i[read update autoriser_compte revoquer_compte play destroy],
                                    Campagne.new(compte: compte))
      expect(subject).not_to be_able_to(:destroy, campagne_superadmin)
      expect(subject).to be_able_to(:read, Questionnaire.new)
      expect(subject).to be_able_to(:read, Situation.new)
      expect(subject).to be_able_to(:manage, Restitution::Base.new(campagne_privee, nil))
      expect(subject).to be_able_to(:read, Actualite.new)
      expect(subject).to be_able_to(:read, ActiveAdmin::Page.new(:admin, 'Aide', {}))
      expect(subject).to be_able_to(:read, ActiveAdmin::Page.new(:admin, 'Dashboard', {}))
      expect(subject).not_to be_able_to(:read,
                                        ActiveAdmin::Page.new(:admin, 'recherche_structure', {}))
      expect(subject).to be_able_to(:fusionner, Beneficiaire)
    end

    context "quand la structure n'autorise pas la création de campagne" do
      before do
        compte.structure.update(autorisation_creation_campagne: false)
      end

      it do
        expect(subject).not_to be_able_to(:create, Campagne)
        expect(subject).not_to be_able_to(:duplique, Campagne)
      end
    end

    context "quand la structure autorise la création de campagne" do
      before do
        compte.structure.update(autorisation_creation_campagne: true)
      end

      it do
        expect(subject).to be_able_to(:create, Campagne)
        expect(subject).to be_able_to(:duplique, Campagne)
      end
    end

    context "quand j'ai accès à la campagne privé d'un autre conseiller" do
      before do
        campagne_collegue.campagne_compte_autorisations.create!(compte_id: compte.id)
      end

      it do
        expect(subject).to be_able_to(:read, campagne_collegue)
        expect(subject).to be_able_to(:read, evaluation_autre_conseiller)
        expect(subject).to be_able_to(:read, evaluation_autre_conseiller.beneficiaire)
      end
    end

    context "quand je n'ai pas accès à la campagne privé d'un autre conseiller" do
      it do
        expect(subject).not_to be_able_to(:read, campagne_collegue)
        expect(subject).not_to be_able_to(:read, evaluation_autre_conseiller)
        expect(subject).not_to be_able_to(:read, evaluation_autre_conseiller.beneficiaire)
      end
    end

    context 'peut consulter les campagnes publiques de ma structure' do
      let(:evaluation_collegue) { create :evaluation, campagne: campagne_collegue }
      let!(:partie_collegue) do
        create :partie, evaluation: evaluation_collegue, situation: situation
      end

      before do
        campagne_collegue.update(privee: false)
      end

      it do
        expect(subject).to be_able_to(:read, evaluation_collegue)
        expect(subject).to be_able_to(:read, evaluation_collegue.beneficiaire)
        expect(subject).not_to be_able_to(:destroy, evaluation_collegue)
        expect(subject).to be_able_to(:manage, Restitution::Base.new(campagne_collegue, nil))
        expect(subject).to be_able_to(:read, mon_collegue)
        expect(subject).to be_able_to(:read, campagne_collegue)
        expect(subject).not_to be_able_to(%i[update destroy], campagne_collegue)
        expect(subject).not_to be_able_to(%i[autoriser_compte revoquer_compte], campagne_collegue)
      end
    end

    context 'pour un compte en attente' do
      let(:mon_collegue) do
        create :compte_conseiller, :en_attente, structure: compte_conseiller.structure
      end

      it do
        expect(subject).not_to be_able_to(:verifier, mon_collegue)
        expect(subject).not_to be_able_to(:autoriser, mon_collegue)
        expect(subject).not_to be_able_to(:refuser, mon_collegue)
      end
    end

    context 'pour un compte refusé' do
      let(:mon_collegue) do
        create :compte_conseiller, :refusee, structure: compte_conseiller.structure
      end

      it do
        expect(subject).not_to be_able_to(:verifier, mon_collegue)
        expect(subject).not_to be_able_to(:autoriser, mon_collegue)
        expect(subject).not_to be_able_to(:refuser, mon_collegue)
      end
    end

    context 'pour un compte accepté' do
      let(:mon_collegue) do
        create :compte_conseiller, :acceptee, structure: compte_conseiller.structure
      end

      it do
        expect(subject).not_to be_able_to(:verifier, mon_collegue)
        expect(subject).not_to be_able_to(:autoriser, mon_collegue)
        expect(subject).not_to be_able_to(:refuser, mon_collegue)
      end
    end

    context "peut envoyer une invitation uniquement pour sa structure" do
      let(:ma_structure) { create :structure_locale, :avec_admin }
      let(:compte) { create :compte_conseiller, structure: ma_structure }
      let(:autre_structure) { create :structure_locale, :avec_admin }

      it "peut envoyer une invitation pour sa propre structure" do
        expect(subject).to be_able_to(:envoyer_invitation, ma_structure)
      end

      it "ne peut pas envoyer une invitation pour une autre structure" do
        expect(subject).not_to be_able_to(:envoyer_invitation, autre_structure)
      end
    end
  end

  context 'Compte en attente de validation' do
    let!(:compte) { create :compte_conseiller, :en_attente, structure: structure_avec_admin }
    let!(:ma_campagne) { create :campagne, compte: compte }
    let!(:mon_evaluation) { create :evaluation, campagne: ma_campagne }

    let!(:autre_compte) { create :compte_conseiller, structure: compte.structure }
    let!(:autre_campagne) { create :campagne, compte: autre_compte }
    let!(:autre_evaluation) { create :evaluation, campagne: autre_campagne }

    it do
      expect(subject).to be_able_to(:read, ma_campagne)
      expect(subject).to be_able_to(:read, compte)
      expect(subject).not_to be_able_to(:read, autre_compte)
      expect(subject).not_to be_able_to(:update, autre_compte)
      expect(subject).not_to be_able_to(:read, autre_campagne)
      expect(subject).not_to be_able_to(:destroy, autre_campagne)
      expect(subject).not_to be_able_to(:read, autre_evaluation)
      expect(subject).not_to be_able_to(:destroy, autre_evaluation)
      expect(subject).not_to be_able_to(:read, compte.structure)
    end
  end

  context 'Compte refusé' do
    let!(:compte) { create :compte_conseiller, :refusee, structure: structure_avec_admin }

    it do
      expect(subject).to be_able_to(:read, compte)
      expect(subject).to be_able_to(:update, compte)
      expect(subject).to be_able_to(:accepter_cgu, compte)
      expect(subject).not_to be_able_to(:read, Campagne)
      expect(subject).not_to be_able_to(:read, Actualite)
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

  context 'Sans compte (utilisateur non connecté)' do
    let(:compte) { nil }

    it "ne génère pas d'erreur et n'autorise rien" do
      expect { ability }.not_to raise_error
      expect(subject).not_to be_able_to(:read, Campagne)
      expect(subject).not_to be_able_to(:read, Evaluation)
      expect(subject).not_to be_able_to(:manage, :all)
    end
  end
end
