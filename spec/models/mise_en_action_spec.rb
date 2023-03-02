# frozen_string_literal: true

require 'rails_helper'

describe MiseEnAction, type: :model do
  it { is_expected.to belong_to(:evaluation) }
  it do
    subject.evaluation = create(:evaluation, :avec_mise_en_action)
    is_expected.to validate_uniqueness_of(:evaluation_id).case_insensitive
  end

  it "valide que effectuee n'est pas vide" do
    should_not allow_value(nil).for(:effectuee)
    should allow_value(true).for(:effectuee)
    should allow_value(false).for(:effectuee)
  end

  describe '#effectuee_avec_dispositif_remediation?' do
    let!(:mise_en_action) { create :mise_en_action, effectuee: true }

    context 'quand la mise en action est effectée et a un dispositif de remédiation' do
      before { mise_en_action.update dispositif_de_remediation: 'formation_metier' }

      it 'renvoie true' do
        expect(mise_en_action.effectuee_avec_dispositif_remediation?).to be true
      end
    end

    context "quand la mise en action est effectée et n'a pas de dispositif de remédiation" do
      it 'renvoie false' do
        expect(mise_en_action.effectuee_avec_dispositif_remediation?).to be false
      end
    end
  end

  describe '#non_effectuee_avec_difficulte?' do
    let!(:mise_en_action) { create :mise_en_action, effectuee: false }

    context "quand la mise en action n'est pas effectuee et a une difficulte" do
      before { mise_en_action.update difficulte: 'freins_peripheriques' }

      it 'renvoie true' do
        expect(mise_en_action.non_effectuee_avec_difficulte?).to be true
      end
    end

    context "quand la mise en action n'est pas effectuee et n'a pas de difficulte" do
      it 'renvoie false' do
        expect(mise_en_action.non_effectuee_avec_difficulte?).to be false
      end
    end
  end
end
