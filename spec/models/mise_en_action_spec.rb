require 'rails_helper'

describe MiseEnAction, type: :model do
  it { is_expected.to belong_to(:evaluation) }

  it do
    subject.evaluation = create(:evaluation, :avec_mise_en_action)
    expect(subject).to validate_uniqueness_of(:evaluation_id).case_insensitive
  end

  it "valide que effectuee n'est pas vide" do
    expect(subject).not_to allow_value(nil).for(:effectuee)
    expect(subject).to allow_value(true).for(:effectuee)
    expect(subject).to allow_value(false).for(:effectuee)
  end

  describe '#effectuee_avec_remediation?' do
    let!(:mise_en_action) { create :mise_en_action, effectuee: true }

    context 'quand la mise en action est effectée et a un dispositif de remédiation' do
      before { mise_en_action.update remediation: 'formation_metier' }

      it 'renvoie true' do
        expect(mise_en_action.effectuee_avec_remediation?).to be true
      end
    end

    context "quand la mise en action est effectée et n'a pas de dispositif de remédiation" do
      it 'renvoie false' do
        expect(mise_en_action.effectuee_avec_remediation?).to be false
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

  describe '#qualification' do
    context 'quand la mise en action est effectuee' do
      let!(:mise_en_action) do
        create :mise_en_action, effectuee: true, remediation: 'formation_metier'
      end

      it 'renvoie le dispositif de remédiation' do
        expect(mise_en_action.qualification).to eq 'formation_metier'
      end
    end

    context "quand la mise en action n'est pas effectuee" do
      let!(:mise_en_action) do
        create :mise_en_action, effectuee: false, difficulte: 'freins_peripheriques'
      end

      it 'renvoie la difficulte' do
        expect(mise_en_action.qualification).to eq 'freins_peripheriques'
      end
    end
  end

  describe '#questionnaire' do
    let!(:mise_en_action) { create :mise_en_action, effectuee: true }

    context 'quand la mise en action est effectuee' do
      it 'renvoie :remediation' do
        expect(mise_en_action.questionnaire).to eq :remediation
      end
    end

    context "quand la mise en action n'est pas effectuee" do
      before { mise_en_action.update effectuee: false }

      it 'renvoie :difficulte' do
        expect(mise_en_action.questionnaire).to eq :difficulte
      end
    end
  end
end
