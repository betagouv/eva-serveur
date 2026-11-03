require 'rails_helper'

describe MiseEnAction, type: :model do
  it { is_expected.to belong_to(:evaluation) }

  it do
    subject.evaluation = create(:evaluation, :eva, :avec_mise_en_action)
    expect(subject).to validate_uniqueness_of(:evaluation_id).case_insensitive
  end

  it "accepte que effectuee soit vide, pour la réponse « je ne sais pas »" do
    expect(subject).to allow_value(nil).for(:effectuee)
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

    context "quand on ne sait pas si la mise en action est effectuee" do
      let!(:mise_en_action) do
        create :mise_en_action, effectuee: nil, motif: 'action_prevue'
      end

      it 'renvoie le motif' do
        expect(mise_en_action.qualification).to eq 'action_prevue'
      end
    end
  end

  describe "#libelle_qualification" do
    it "traduit la remédiation quand la mise en action est effectuée" do
      mise_en_action = build(:mise_en_action, effectuee: true, remediation: "formation_metier")

      expect(mise_en_action.libelle_qualification)
        .to eq I18n.t("activerecord.attributes.mise_en_action.remediation.formation_metier")
    end

    it "traduit la difficulté quand la mise en action n'est pas effectuée" do
      mise_en_action = build(:mise_en_action, effectuee: false, difficulte: "freins_peripheriques")

      expect(mise_en_action.libelle_qualification)
        .to eq I18n.t("activerecord.attributes.mise_en_action.difficulte.freins_peripheriques")
    end

    it "ne renvoie rien quand la qualification est indéterminée" do
      mise_en_action = build(:mise_en_action, effectuee: true, remediation: MiseEnAction::QUALIFICATION_INDETERMINEE)

      expect(mise_en_action.libelle_qualification).to be_nil
    end

    it "ne renvoie rien sans qualification" do
      mise_en_action = build(:mise_en_action, effectuee: true)

      expect(mise_en_action.libelle_qualification).to be_nil
    end
  end

  describe "cohérence de la qualification" do
    it "accepte une remédiation sur une réponse Oui" do
      expect(build(:mise_en_action, effectuee: true, remediation: "formation_metier")).to be_valid
    end

    it "accepte une difficulté sur une réponse Non" do
      expect(build(:mise_en_action, effectuee: false, difficulte: "freins_peripheriques"))
        .to be_valid
    end

    it "refuse une difficulté sur une réponse Oui" do
      mise_en_action = build(:mise_en_action, effectuee: true, difficulte: "freins_peripheriques")

      expect(mise_en_action).not_to be_valid
      expect(mise_en_action.errors).to be_added(:base, :difficulte_incoherente)
    end

    it "refuse une remédiation sur une réponse Non" do
      mise_en_action = build(:mise_en_action, effectuee: false, remediation: "formation_metier")

      expect(mise_en_action).not_to be_valid
      expect(mise_en_action.errors).to be_added(:base, :remediation_incoherente)
    end

    it "refuse une remédiation ou une difficulté sur une réponse « je ne sais pas »" do
      mise_en_action = build(:mise_en_action, effectuee: nil, remediation: "formation_metier",
                                              difficulte: "freins_peripheriques")

      expect(mise_en_action).not_to be_valid
      expect(mise_en_action.errors).to be_added(:base, :remediation_incoherente)
      expect(mise_en_action.errors).to be_added(:base, :difficulte_incoherente)
    end
  end

  describe "précision de la réponse « Autre »" do
    it "refuse un type d'aide « Autre » sans précision" do
      mise_en_action = build(:mise_en_action, effectuee: true, remediation: "autre")

      expect(mise_en_action).not_to be_valid
      expect(mise_en_action.errors).to be_added(:precision_autre, :blank_remediation)
      expect(mise_en_action.errors[:precision_autre])
        .to include I18n.t("activerecord.errors.models.mise_en_action.attributes" \
                           ".precision_autre.blank_remediation")
    end

    it "refuse une raison « Autre » avec des espaces seulement" do
      mise_en_action = build(:mise_en_action, effectuee: false, difficulte: "autre",
                                              precision_autre: "   \n ")

      expect(mise_en_action).not_to be_valid
      expect(mise_en_action.errors).to be_added(:precision_autre, :blank_difficulte)
    end

    it "refuse une précision de plus de 200 caractères" do
      mise_en_action = build(:mise_en_action, effectuee: true, remediation: "autre",
                                              precision_autre: "a" * 201)

      expect(mise_en_action).not_to be_valid
      expect(mise_en_action.errors).to be_added(:precision_autre, :too_long, count: 200)
    end

    it "accepte « Autre » avec une précision, sans les espaces autour et avec ses sauts de ligne" do
      mise_en_action = build(:mise_en_action, effectuee: false, difficulte: "autre",
                                              precision_autre: "  déménagement\n- le mois  ")

      expect(mise_en_action).to be_valid
      expect(mise_en_action.precision_autre).to eq "déménagement\n- le mois"
    end

    it "efface la précision quand un autre type d'aide est choisi" do
      mise_en_action = create(:mise_en_action, effectuee: true, remediation: "autre",
                                               precision_autre: "aide sur mesure")

      mise_en_action.update!(remediation: "formation_metier")

      expect(mise_en_action.reload.precision_autre).to be_nil
    end

    it "efface la précision quand la réponse change" do
      evaluation = create(:evaluation, :eva)
      mise_en_action = create(:mise_en_action, evaluation: evaluation, effectuee: true,
                                               remediation: "autre",
                                               precision_autre: "aide sur mesure")

      evaluation.enregistre_mise_en_action(false)

      expect(mise_en_action.reload.precision_autre).to be_nil
    end
  end

  describe "#qualification_indeterminee?" do
    it "est vrai quand la remédiation est indéterminée" do
      mise_en_action = build(:mise_en_action, effectuee: true,
                                              remediation: MiseEnAction::QUALIFICATION_INDETERMINEE)

      expect(mise_en_action.qualification_indeterminee?).to be(true)
    end

    it "est vrai quand la difficulté est indéterminée" do
      mise_en_action = build(:mise_en_action, effectuee: false,
                                              difficulte: MiseEnAction::QUALIFICATION_INDETERMINEE)

      expect(mise_en_action.qualification_indeterminee?).to be(true)
    end

    it "est faux quand une remédiation est choisie" do
      mise_en_action = build(:mise_en_action, effectuee: true, remediation: "formation_metier")

      expect(mise_en_action.qualification_indeterminee?).to be(false)
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

    context "quand on ne sait pas si la mise en action est effectuee" do
      before { mise_en_action.update effectuee: nil }

      it 'renvoie :motif' do
        expect(mise_en_action.questionnaire).to eq :motif
      end
    end
  end
end
