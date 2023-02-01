# frozen_string_literal: true

require 'rails_helper'

describe Evaluation do
  it { is_expected.to validate_presence_of :nom }
  it { is_expected.to validate_presence_of :debutee_le }
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
end
