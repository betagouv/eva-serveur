require 'rails_helper'

describe MiseEnAction, type: :model do
  it { is_expected.to belong_to(:evaluation) }

  it { is_expected.to belong_to(:beneficiaire) }
  it { is_expected.to belong_to(:structure) }

  describe "une seule mise en action en cours par personne et par structure" do
    let(:existante) { create(:mise_en_action) }

    it "refuse une seconde déclaration en cours dans la même structure" do
      doublon = build(:mise_en_action, beneficiaire: existante.beneficiaire,
                                       structure: existante.structure)
      expect(doublon).not_to be_valid
    end

    it "accepte une déclaration dans une autre structure" do
      autre = build(:mise_en_action, beneficiaire: existante.beneficiaire,
                                     structure: create(:structure_locale))
      expect(autre).to be_valid
    end

    it "accepte une nouvelle déclaration quand la précédente est remplacée" do
      existante.remplace!
      nouvelle = build(:mise_en_action, beneficiaire: existante.beneficiaire,
                                        structure: existante.structure)
      expect(nouvelle).to be_valid
    end
  end

  it "accepte que effectuee soit vide, pour la réponse « Pas encore »" do
    expect(subject).to allow_value(nil).for(:effectuee)
    expect(subject).to allow_value(true).for(:effectuee)
    expect(subject).to allow_value(false).for(:effectuee)
  end

  describe ".repondues_pas_encore" do
    let!(:pas_encore) { create(:mise_en_action, effectuee: nil) }
    let!(:oui) { create(:mise_en_action, effectuee: true) }
    let!(:non) { create(:mise_en_action, effectuee: false) }

    it "ne garde que les mises en action auxquelles on a répondu Pas encore" do
      expect(described_class.repondues_pas_encore).to contain_exactly(pas_encore)
    end

    it "ne garde pas une mise en action à laquelle on n'a jamais répondu" do
      jamais_repondue = create(:mise_en_action, effectuee: nil, repondue_le: nil)

      expect(described_class.repondues_pas_encore).not_to include(jamais_repondue)
    end
  end

  describe ".reportees" do
    # La date de revue a été choisie la veille, quand elle était encore dans le futur
    let!(:pas_encore) do
      Timecop.freeze(date_revue - 1) do
        create(:mise_en_action, effectuee: nil, date_revue: date_revue)
      end
    end

    context "quand on a répondu Pas encore avec une date de revue dans le futur" do
      let(:date_revue) { Date.current + 1 }

      it "la mise en action est reportée" do
        expect(described_class.reportees).to include(pas_encore)
      end
    end

    context "quand on a répondu Pas encore et que la date de revue est aujourd'hui" do
      let(:date_revue) { Date.current }

      it "la mise en action n'est plus reportée" do
        expect(described_class.reportees).not_to include(pas_encore)
      end
    end

    context "quand on a répondu Pas encore et que la date de revue est passée" do
      let(:date_revue) { Date.current - 1 }

      it "la mise en action n'est plus reportée" do
        expect(described_class.reportees).not_to include(pas_encore)
      end
    end

    context "quand on a répondu Oui, même avec une date de revue dans le futur" do
      let(:date_revue) { Date.current + 1 }
      let!(:oui) do
        Timecop.freeze(date_revue - 1) do
          create(:mise_en_action, effectuee: true, date_revue: date_revue)
        end
      end

      it "la mise en action n'est pas reportée" do
        expect(described_class.reportees).not_to include(oui)
      end
    end
  end

  describe "#date_revue_a_choisir?" do
    context "quand le pro a répondu Pas encore sans avoir choisi de date de revue" do
      it "la date de revue est à choisir" do
        mise_en_action = build(:mise_en_action, effectuee: nil, date_revue: nil)

        expect(mise_en_action.date_revue_a_choisir?).to be(true)
      end
    end

    context "quand le pro a répondu Pas encore et choisi une date de revue" do
      it "la date de revue n'est plus à choisir" do
        mise_en_action = build(:mise_en_action, effectuee: nil, date_revue: Date.current + 7)

        expect(mise_en_action.date_revue_a_choisir?).to be(false)
      end
    end

    context "quand le pro a répondu Oui" do
      it "il n'y a pas de date de revue à choisir" do
        mise_en_action = build(:mise_en_action, effectuee: true)

        expect(mise_en_action.date_revue_a_choisir?).to be(false)
      end
    end
  end

  describe "#date_de_revue_atteinte?" do
    let(:pas_encore) { build(:mise_en_action, effectuee: nil, date_revue: date_revue) }

    context "quand on a répondu Pas encore et que la date de revue est aujourd'hui" do
      let(:date_revue) { Date.current }

      it "la date de revue est atteinte" do
        expect(pas_encore.date_de_revue_atteinte?).to be(true)
      end
    end

    context "quand on a répondu Pas encore avec une date de revue dans le futur" do
      let(:date_revue) { Date.current + 1 }

      it "la date de revue n'est pas atteinte" do
        expect(pas_encore.date_de_revue_atteinte?).to be(false)
      end
    end

    context "quand on a répondu Pas encore sans avoir choisi de date de revue" do
      let(:date_revue) { nil }

      it "il n'y a pas de date de revue à atteindre" do
        expect(pas_encore.date_de_revue_atteinte?).to be(false)
      end
    end
  end

  describe "#reportee?" do
    let(:pas_encore) { build(:mise_en_action, effectuee: nil, date_revue: date_revue) }

    context "quand on a répondu Pas encore avec une date de revue dans le futur" do
      let(:date_revue) { Date.current + 1 }

      it "la mise en action est reportée" do
        expect(pas_encore.reportee?).to be(true)
      end
    end

    context "quand on a répondu Pas encore et que la date de revue est aujourd'hui" do
      let(:date_revue) { Date.current }

      it "la mise en action n'est plus reportée" do
        expect(pas_encore.reportee?).to be(false)
      end
    end

    context "quand on a répondu Pas encore sans avoir choisi de date de revue" do
      let(:date_revue) { nil }

      it "la mise en action n'est pas reportée" do
        expect(pas_encore.reportee?).to be(false)
      end
    end
  end

  describe "#repondu_oui?" do
    it "n'est vrai que pour une réponse Oui" do
      expect(build(:mise_en_action, effectuee: true).repondu_oui?).to be(true)
      expect(build(:mise_en_action, effectuee: false).repondu_oui?).to be(false)
      expect(build(:mise_en_action, effectuee: nil).repondu_oui?).to be(false)
    end
  end

  describe "#repondu_non?" do
    it "n'est vrai que pour une réponse Non" do
      expect(build(:mise_en_action, effectuee: false).repondu_non?).to be(true)
      expect(build(:mise_en_action, effectuee: true).repondu_non?).to be(false)
      expect(build(:mise_en_action, effectuee: nil).repondu_non?).to be(false)
    end
  end

  describe "#repondu_pas_encore?" do
    it "n'est vrai que pour une réponse Pas encore" do
      expect(build(:mise_en_action, effectuee: nil).repondu_pas_encore?).to be(true)
      expect(build(:mise_en_action, effectuee: true).repondu_pas_encore?).to be(false)
      expect(build(:mise_en_action, effectuee: false).repondu_pas_encore?).to be(false)
    end

    it "est faux quand le pro n'a pas encore répondu" do
      expect(build(:mise_en_action, effectuee: nil, repondue_le: nil).repondu_pas_encore?)
        .to be(false)
    end
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

    context "quand le type d'aide a été ignoré depuis le tableau de bord" do
      before { mise_en_action.update remediation: 'indetermine' }

      it 'renvoie false' do
        expect(mise_en_action.effectuee_avec_remediation?).to be false
      end
    end
  end

  describe '#effectuee_sans_remediation?' do
    it "est vrai pour une réponse Oui sans type d'aide ou avec un type d'aide ignoré" do
      expect(build(:mise_en_action, effectuee: true).effectuee_sans_remediation?).to be(true)
      expect(build(:mise_en_action, effectuee: true, remediation: 'indetermine')
               .effectuee_sans_remediation?).to be(true)
    end

    it "est faux pour une réponse Oui avec un type d'aide ou pour une autre réponse" do
      expect(build(:mise_en_action, effectuee: true, remediation: 'formation_metier')
               .effectuee_sans_remediation?).to be(false)
      expect(build(:mise_en_action, effectuee: false).effectuee_sans_remediation?).to be(false)
    end
  end

  describe '#non_effectuee_sans_difficulte?' do
    it "est vrai pour une réponse Non sans raison ou avec une raison ignorée" do
      expect(build(:mise_en_action, effectuee: false).non_effectuee_sans_difficulte?).to be(true)
      expect(build(:mise_en_action, effectuee: false, difficulte: 'indetermine')
               .non_effectuee_sans_difficulte?).to be(true)
    end

    it "est faux pour une réponse Non avec une raison ou pour une autre réponse" do
      expect(build(:mise_en_action, effectuee: false, difficulte: 'freins_peripheriques')
               .non_effectuee_sans_difficulte?).to be(false)
      expect(build(:mise_en_action, effectuee: true).non_effectuee_sans_difficulte?).to be(false)
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

    context "quand la raison a été ignorée depuis le tableau de bord" do
      before { mise_en_action.update difficulte: 'indetermine' }

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

    it "affiche la précision d'une réponse « Autre »" do
      mise_en_action = build(:mise_en_action, effectuee: false, difficulte: "autre",
                                              precision_autre: "déménagement")

      expect(mise_en_action.libelle_qualification)
        .to eq I18n.t("reponse_mise_en_action.autre", precision: "déménagement")
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

    it "refuse une remédiation ou une difficulté sur une réponse « Pas encore »" do
      mise_en_action = build(:mise_en_action, effectuee: nil, remediation: "formation_metier",
                                              difficulte: "freins_peripheriques")

      expect(mise_en_action).not_to be_valid
      expect(mise_en_action.errors).to be_added(:base, :remediation_incoherente)
      expect(mise_en_action.errors).to be_added(:base, :difficulte_incoherente)
    end
  end

  describe "#qualifie" do
    let(:mise_en_action) { create(:mise_en_action, effectuee: true) }

    it "enregistre le type d'aide sur une réponse Oui" do
      expect(mise_en_action.qualifie("true", "formation_metier", nil)).to be(true)

      expect(mise_en_action.reload).to have_attributes(effectuee: true,
                                                       remediation: "formation_metier")
    end

    it "enregistre la raison sur une réponse Non" do
      expect(mise_en_action.qualifie("false", "freins_peripheriques", nil)).to be(true)

      expect(mise_en_action.reload).to have_attributes(effectuee: false,
                                                       difficulte: "freins_peripheriques")
    end

    it "enregistre « Autre » avec sa précision" do
      mise_en_action.qualifie("true", "autre", "aide sur mesure")

      expect(mise_en_action.reload).to have_attributes(remediation: "autre",
                                                       precision_autre: "aide sur mesure")
    end

    it "n'enregistre rien et renvoie false quand la qualification est refusée" do
      expect(mise_en_action.qualifie("true", "autre", "")).to be(false)

      expect(mise_en_action.reload.remediation).to be_nil
    end
  end

  describe "#reporte_dans" do
    let(:repondue_le) { Time.zone.local(2026, 11, 2, 10) }
    let(:pas_encore) { create(:mise_en_action, effectuee: nil, repondue_le: repondue_le) }

    context "quand le pro choisit « Dans 14 jours »" do
      it "fixe la revue dans 14 jours et garde son choix, sans changer la date de réponse" do
        pas_encore.reporte_dans("14_jours")

        pas_encore.reload
        expect(pas_encore.date_revue).to eq(Date.current + 14)
        expect(pas_encore.choix_date_revue).to eq("14_jours")
        expect(pas_encore.repondue_le).to eq(repondue_le)
      end
    end

    context "quand le pro choisit « Dans 1 mois » un 31 janvier" do
      it "fixe la date de revue au dernier jour de février" do
        Timecop.freeze(Date.new(2027, 1, 31)) { pas_encore.reporte_dans("1_mois") }

        expect(pas_encore.reload.date_revue).to eq(Date.new(2027, 2, 28))
      end
    end

    context "quand le pro choisit une date précise dans le futur" do
      it "enregistre cette date et son choix" do
        pas_encore.reporte_dans(MiseEnAction::CHOIX_DATE_PRECISE, Date.current + 30)

        pas_encore.reload
        expect(pas_encore.date_revue).to eq(Date.current + 30)
        expect(pas_encore.choix_date_revue).to eq(MiseEnAction::CHOIX_DATE_PRECISE)
      end
    end

    context "quand le pro choisit une date précise aujourd'hui" do
      it "refuse la date et demande une date à partir de demain" do
        expect(pas_encore.reporte_dans(MiseEnAction::CHOIX_DATE_PRECISE, Date.current)).to be(false)

        expect(pas_encore.errors[:date_revue]).to eq(
          [ I18n.t("activerecord.errors.models.mise_en_action.attributes" \
                   ".date_revue.a_partir_de_demain") ]
        )
        expect(pas_encore.reload.date_revue).to be_nil
      end
    end

    context "quand le pro choisit une date précise passée" do
      it "refuse la date" do
        hier = Date.current - 1

        expect(pas_encore.reporte_dans(MiseEnAction::CHOIX_DATE_PRECISE, hier)).to be(false)

        expect(pas_encore.reload.date_revue).to be_nil
      end
    end

    context "quand le choix n'est pas un de ceux proposés" do
      it "n'enregistre rien" do
        expect(pas_encore.reporte_dans("3_ans")).to be(false)

        expect(pas_encore.reload.date_revue).to be_nil
      end
    end

    context "quand la date de revue enregistrée est passée depuis" do
      let(:date_revue) { Date.current - 1 }
      let(:pas_encore) do
        Timecop.freeze(date_revue - 1) do
          create(:mise_en_action, effectuee: nil, date_revue: date_revue)
        end
      end

      it "ne la refuse pas tant qu'elle n'est pas modifiée" do
        expect(pas_encore.valid?).to be(true)
      end
    end
  end

  describe "#enregistre_reponse" do
    let(:date_du_jour) { Time.zone.local(2023, 1, 1, 12, 0, 0) }

    it "remplace la date de réponse par la date du jour" do
      mise_en_action = create(:mise_en_action, repondue_le: Time.zone.local(2022, 1, 1))

      Timecop.freeze(date_du_jour) { mise_en_action.enregistre_reponse(false) }

      expect(mise_en_action.reload.repondue_le).to eq(date_du_jour)
    end

    it "remplace Oui par Non et efface le type d'aide" do
      mise_en_action = create(:mise_en_action, effectuee: true, remediation: "formation_metier")

      mise_en_action.enregistre_reponse(false)

      mise_en_action.reload
      expect(mise_en_action.effectuee).to be(false)
      expect(mise_en_action.remediation).to be_nil
    end

    it "remplace Non par Oui et efface la raison" do
      mise_en_action = create(:mise_en_action, effectuee: false,
                                               difficulte: "freins_peripheriques")

      mise_en_action.enregistre_reponse(true)

      mise_en_action.reload
      expect(mise_en_action.effectuee).to be(true)
      expect(mise_en_action.difficulte).to be_nil
    end

    it "remplace Oui par Pas encore et efface le type d'aide, en laissant le pro choisir la date" do
      mise_en_action = create(:mise_en_action, effectuee: true, remediation: "formation_metier")

      mise_en_action.enregistre_reponse(nil)

      mise_en_action.reload
      expect(mise_en_action.effectuee).to be_nil
      expect(mise_en_action.remediation).to be_nil
      expect(mise_en_action.motif).to be_nil
      expect(mise_en_action.date_revue).to be_nil
    end

    it "garde la date de revue et son choix quand on répond de nouveau Pas encore" do
      mise_en_action = create(:mise_en_action, effectuee: nil, date_revue: Date.current + 30,
                                               choix_date_revue: "1_mois")

      mise_en_action.enregistre_reponse(nil)

      mise_en_action.reload
      expect(mise_en_action.date_revue).to eq(Date.current + 30)
      expect(mise_en_action.choix_date_revue).to eq("1_mois")
    end

    it "remplace « Pas encore » par Oui et efface le motif, la date de revue et son choix" do
      mise_en_action = create(:mise_en_action, effectuee: nil, motif: "action_prevue",
                                               date_revue: Date.current + 7,
                                               choix_date_revue: "7_jours")

      mise_en_action.enregistre_reponse(true)

      mise_en_action.reload
      expect(mise_en_action.effectuee).to be(true)
      expect(mise_en_action.motif).to be_nil
      expect(mise_en_action.date_revue).to be_nil
      expect(mise_en_action.choix_date_revue).to be_nil
    end

    it "efface la précision d'un « Autre » quand la réponse change" do
      mise_en_action = create(:mise_en_action, effectuee: true, remediation: "autre",
                                               precision_autre: "aide sur mesure")

      mise_en_action.enregistre_reponse(false)

      expect(mise_en_action.reload.precision_autre).to be_nil
    end
  end

  describe "date de la réponse « Choisir une date »" do
    it "refuse le choix d'une date précise sans date" do
      mise_en_action = build(:mise_en_action, effectuee: nil,
                                              choix_date_revue: MiseEnAction::CHOIX_DATE_PRECISE)

      expect(mise_en_action.valid?).to be(false)
      expect(mise_en_action.errors[:date_revue]).to eq(
        [ I18n.t("activerecord.errors.models.mise_en_action.attributes" \
                 ".date_revue.a_partir_de_demain") ]
      )
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
