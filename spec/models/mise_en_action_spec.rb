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

  describe '#effectuee_sans_dispositif_remediation?' do
    context "quand la mise en action est effectée mais n'a pas de dispositif de remédiation" do
      let!(:mise_en_action) { create :mise_en_action, effectuee: true }

      it 'renvoie true' do
        expect(mise_en_action.effectuee_sans_dispositif_remediation?).to be true
      end
    end

    context 'quand la mise en action est effectée et a une réponse au dispositif de remédiation' do
      let!(:mise_en_action) do
        create :mise_en_action, effectuee: true, dispositif_de_remediation: 'formation_metier'
      end

      it 'renvoie false' do
        expect(mise_en_action.effectuee_sans_dispositif_remediation?).to be false
      end
    end
  end
end
