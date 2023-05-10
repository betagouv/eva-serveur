# frozen_string_literal: true

require 'rails_helper'

describe Evaluation do
  it { is_expected.to validate_presence_of :nom }
  it { is_expected.to validate_presence_of :debutee_le }
  it { is_expected.to validate_presence_of :statut }
  it { is_expected.to belong_to :campagne }
  it { is_expected.to belong_to(:responsable_suivi).optional }
  it { should accept_nested_attributes_for :beneficiaire }
  it { is_expected.to have_one :conditions_passation }
  it { should accept_nested_attributes_for :conditions_passation }
  it { is_expected.to have_one :donnee_sociodemographique }
  it { should accept_nested_attributes_for :donnee_sociodemographique }

  describe 'scopes' do
    describe '.des_12_derniers_mois' do
      it 'ne récupère pas les évaluations du mois courant' do
        Timecop.freeze(Time.zone.local(2023, 1, 10, 12, 0, 0)) do
          Timecop.freeze(Time.zone.local(2023, 1, 1, 0, 0, 0)) { create(:evaluation) }

          expect(Evaluation.des_12_derniers_mois.count).to eq 0
        end
      end

      it 'récupère les évaluations du mois dernier' do
        Timecop.freeze(Time.zone.local(2023, 1, 10, 12, 0, 0)) do
          Timecop.freeze(Time.zone.local(2022, 12, 31, 23, 59, 59)) { create(:evaluation) }

          expect(Evaluation.des_12_derniers_mois.count).to eq 1
        end
      end

      it "récupère les évaluations d'il y a moins de 12 mois" do
        Timecop.freeze(Time.zone.local(2023, 1, 10, 12, 0, 0)) do
          Timecop.freeze(Time.zone.local(2022, 1, 1, 0, 0, 0)) { create(:evaluation) }

          expect(Evaluation.des_12_derniers_mois.count).to eq 1
        end
      end

      it "ne récupère pas les évaluations d'il y a plus de 12 mois" do
        Timecop.freeze(Time.zone.local(2023, 1, 10, 12, 0, 0)) do
          Timecop.freeze(Time.zone.local(2021, 12, 31, 23, 59, 59)) { create(:evaluation) }

          expect(Evaluation.des_12_derniers_mois.count).to eq 0
        end
      end
    end

    describe '.non_anonymes' do
      let(:evaluation_anonyme) { create :evaluation, anonymise_le: Time.zone.today }
      let(:evaluation_non_anonyme) { create :evaluation, anonymise_le: nil }

      it 'retourne les évaluations qui ne sont pas anonymisées' do
        expect(described_class.non_anonymes).to eq [evaluation_non_anonyme]
      end
    end

    describe '.sans_mise_en_action' do
      let!(:evaluation_avec_mise_en_action) { create :evaluation, :avec_mise_en_action }
      let!(:evaluation_sans_mise_en_action) { create :evaluation }

      it 'retourne les évaluations sans mise en action' do
        expect(described_class.sans_mise_en_action).to eq [evaluation_sans_mise_en_action]
      end
    end

    describe '.competences_de_base_completes' do
      let!(:evaluation_complete) { create :evaluation, completude: 'complete' }
      let!(:evaluation_incomplete) { create :evaluation, completude: 'incomplete' }
      let!(:evaluation_transversales_incompletes) do
        create :evaluation, completude: 'competences_transversales_incompletes'
      end

      it do
        expect(described_class.competences_de_base_completes).to contain_exactly(
          evaluation_transversales_incompletes,
          evaluation_complete
        )
      end
    end
  end

  describe '#responsables_suivi' do
    let!(:structure) { create :structure }
    let!(:structure2) { create :structure }
    let!(:compte1) { create :compte, structure: structure }
    let!(:compte2) { create :compte, structure: structure }
    let!(:compte_en_attente) { create :compte_conseiller, :en_attente, structure: structure }
    let!(:compte_refusee) { create :compte_conseiller, :refusee, structure: structure }
    let!(:compte_autre_structure) { create :compte, structure: structure2 }
    let!(:campagne) { create :campagne, compte: compte1 }
    let!(:evaluation) { create :evaluation, campagne: campagne }

    it "retourne les responsables de suivi possible pour l'évaluation" do
      expect(evaluation.responsables_suivi).to contain_exactly(compte1, compte2)
    end
  end

  describe '#enregistre_mise_en_action' do
    context 'lorsque la mise en action existe déjà' do
      let(:date_mise_en_action) { Time.zone.local(2022, 1, 1, 12, 0, 0) }
      let!(:evaluation) do
        create :evaluation, :avec_mise_en_action, repondue_le: date_mise_en_action
      end

      before { evaluation.enregistre_mise_en_action(false) }

      it 'met à jour la réponse mais pas la date de mise en action' do
        expect(evaluation.reload.mise_en_action.effectuee).to eq false
        expect(evaluation.reload.mise_en_action.repondue_le).to eq date_mise_en_action
      end
    end

    context "quand il n'y a pas de mise en action associée" do
      let!(:evaluation) { create :evaluation }

      it 'créé et enregistre true en réponse' do
        date_du_jour = Time.zone.local(2023, 1, 1, 12, 0, 0)
        Timecop.freeze(date_du_jour) do
          evaluation.enregistre_mise_en_action(true)
        end
        expect(evaluation.mise_en_action.effectuee).to eq true
        expect(evaluation.mise_en_action.repondue_le).to eq date_du_jour
      end

      it 'créé et enregistre false en réponse' do
        evaluation.enregistre_mise_en_action(false)
        expect(evaluation.mise_en_action.effectuee).to eq false
      end
    end
  end

  describe '#a_mise_en_action?' do
    context "quand aucune mise en action n'est associée à l'évaluation" do
      let!(:evaluation) { create :evaluation }

      it { expect(evaluation.a_mise_en_action?).to eq false }
    end

    context "quand une mise en action est associée à l'évaluation" do
      context 'quand la mise en action a été effectué' do
        let!(:evaluation) { create :evaluation, :avec_mise_en_action }

        it { expect(evaluation.a_mise_en_action?).to eq true }
      end

      context "quand la mise en action n'a pas été effectué" do
        let!(:evaluation) { create :evaluation, :avec_mise_en_action, effectuee: false }

        it { expect(evaluation.reload.a_mise_en_action?).to eq true }
      end
    end
  end

  describe '#tableau_de_bord_mises_en_action' do
    let(:compte_admin) { create :compte_admin }
    let(:campagne) { create :campagne, compte: compte_admin }
    let!(:evaluation_sans_mise_en_action) do
      create :evaluation,
             synthese_competences_de_base: :illettrisme_potentiel,
             completude: 'complete',
             campagne: campagne
    end
    let!(:evaluation_sans_difficulte) do
      create :evaluation, :avec_mise_en_action,
             effectuee: false,
             synthese_competences_de_base: :illettrisme_potentiel,
             campagne: campagne
    end
    let!(:evaluation_ni_ni) do
      create :evaluation, synthese_competences_de_base: :ni_ni, campagne: campagne
    end
    let!(:evaluation_sans_dispositif) do
      create :evaluation, :avec_mise_en_action,
             synthese_competences_de_base: :illettrisme_potentiel,
             campagne: campagne
    end
    let!(:evaluation_autre_compte) do
      create :evaluation, synthese_competences_de_base: :illettrisme_potentiel
    end

    it 'retourne les évaluations de mises en action pour le tableau de bord' do
      ability = Ability.new(compte_admin)
      expect(described_class.tableau_de_bord_mises_en_action(ability).pluck(:id))
        .to eq [evaluation_sans_mise_en_action.id]
    end
  end

  describe '#beneficiaires_possibles' do
    let(:compte) { create :compte_admin }
    let(:campagne) { create :campagne, compte: compte }
    let(:evaluation) { create :evaluation, campagne: campagne }
    let(:autre_evaluation) { create :evaluation, campagne: campagne }
    let(:eval_autre_structure) { create :evaluation }

    it 'retourne les bénéficiaires de la structure' do
      expect(evaluation.beneficiaires_possibles).to include(evaluation.beneficiaire)
      expect(evaluation.beneficiaires_possibles).to include(autre_evaluation.beneficiaire)
      expect(evaluation.beneficiaires_possibles).not_to include(eval_autre_structure.beneficiaire)
    end
  end
end
