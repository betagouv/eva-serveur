require 'rails_helper'

describe Evaluation do
  it { is_expected.to validate_presence_of :debutee_le }
  it { is_expected.to validate_presence_of :statut }
  it { is_expected.to belong_to :campagne }
  it { is_expected.to accept_nested_attributes_for :beneficiaire }
  it { is_expected.to have_one :conditions_passation }
  it { is_expected.to accept_nested_attributes_for :conditions_passation }

  describe 'scopes' do
    describe '.non_anonymes' do
      let(:beneficiaire) { create :beneficiaire, anonymise_le: Time.zone.today }
      let(:beneficiaire_non_anonyme) { create :beneficiaire, anonymise_le: nil }
      let(:evaluation_anonyme) { create :evaluation, beneficiaire: beneficiaire }
      let(:evaluation_non_anonyme) { create :evaluation, beneficiaire: beneficiaire_non_anonyme }

      it 'retourne les évaluations qui ne sont pas anonymisées' do
        expect(described_class.non_anonymes).to eq [ evaluation_non_anonyme ]
      end
    end

    describe '.avec_type_de_programme' do
      let!(:evaluation_diagnostic) { create(:evaluation, :diagnostic) }
      let!(:evaluation_positionnement) { create(:evaluation, :positionnement) }

      it 'retourne uniquement les évaluations de type diagnostic' do
        resultats = described_class.avec_type_de_programme(:diagnostic)

        expect(resultats).to include(evaluation_diagnostic)
        expect(resultats).not_to include(evaluation_positionnement)
      end

      it 'retourne uniquement les évaluations de type positionnement' do
        resultats = described_class.avec_type_de_programme(:positionnement)

        expect(resultats).not_to include(evaluation_diagnostic)
        expect(resultats).to include(evaluation_positionnement)
      end
    end

    describe ".pour_structure" do
      let(:structure) { create :structure }
      let(:autre_structure) { create :structure }
      let(:campagne) { create :campagne, compte: create(:compte, structure: structure) }
      let(:autre_campagne) { create :campagne, compte: create(:compte, structure: autre_structure) }
      let!(:evaluation_structure) { create :evaluation, campagne: campagne }
      let!(:evaluation_autre_structure) { create :evaluation, campagne: autre_campagne }

      context "quand la structure est présente" do
        it "retourne les évaluations de la structure" do
          expect(described_class.pour_structure(structure)).to contain_exactly(evaluation_structure)
        end
      end

      context "quand la structure est absente" do
        it "retourne une relation vide" do
          expect(described_class.pour_structure(nil)).to be_empty
        end
      end
    end

    describe ".avec_reponse" do
      let!(:evaluation_avec_reponse) { create :evaluation }
      let!(:evaluation_avec_reponse_intitule) { create :evaluation }
      let!(:evaluation_sans_reponse) { create :evaluation }

      let!(:situation) { create :situation_livraison }
      let!(:partie_avec_reponse) do
        create :partie, evaluation: evaluation_avec_reponse, situation: situation
      end
      let!(:partie_avec_reponse_intitule) do
        create :partie, evaluation: evaluation_avec_reponse_intitule, situation: situation
      end
      let!(:partie_sans_reponse) do
        create :partie, evaluation: evaluation_sans_reponse, situation: situation
      end

      before do
        create :evenement_reponse, partie: partie_avec_reponse, donnees: { "reponse" => "ok" }
        create :evenement_reponse, partie: partie_avec_reponse, donnees: { "reponse" => "autre" }
        create :evenement_reponse,
               partie: partie_avec_reponse_intitule,
               donnees: { "reponseIntitule" => "intitulé", "reponse" => "" }
        create :evenement_reponse, partie: partie_sans_reponse, donnees: { "reponse" => "" }
        create :evenement_reponse, partie: partie_sans_reponse,
donnees: { "reponseIntitule" => nil }
        create :evenement, partie: partie_sans_reponse, donnees: { "reponse" => "ok" }
      end

      context "quand des réponses non vides existent" do
        it "retourne les évaluations qui ont au moins une réponse" do
          expect(described_class.avec_reponse).to contain_exactly(
            evaluation_avec_reponse,
            evaluation_avec_reponse_intitule
          )
        end
      end
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

  describe "#display_name" do
    let(:compte) { create :compte_admin }
    let(:campagne) { create :campagne, compte: compte }
    let(:beneficiaire) { create :beneficiaire, nom: "Toto Martin" }
    let(:evaluation) { create :evaluation, beneficiaire: beneficiaire, campagne: campagne }

    it "retourne le nom du bénéficiaire et la date" do
      evaluation.debutee_le = Time.zone.local(2023, 1, 10, 12, 1, 0)
      expect(evaluation.display_name).to eq("Toto Martin - 10 jan. 2023, 12:01")
    end
  end

  describe ".reponses_redaction_pour_evaluations" do
    let!(:question_redaction) { create :question_saisie, nom_technique: QuestionSaisie::QUESTION_REDACTION }
    let!(:autre_question) { create :question_saisie }
    let!(:evaluation1) { create :evaluation }
    let!(:evaluation2) { create :evaluation }
    let!(:evaluation3) { create :evaluation }

    let!(:situation) { create :situation_livraison }

    let!(:partie1) { create :partie, evaluation: evaluation1, situation: situation }
    let!(:partie2) { create :partie, evaluation: evaluation2, situation: situation }
    let!(:partie3) { create :partie, evaluation: evaluation3, situation: situation }

    before do
      create :evenement_reponse, partie: partie1,
             donnees: { "question" => question_redaction.id, "reponse" => "Première réponse" }
      create :evenement_reponse, partie: partie1,
             donnees: { "question" => question_redaction.id, "reponse" => "Deuxième réponse" }

      create :evenement_reponse, partie: partie2,
             donnees: { "question" => question_redaction.id, "reponse" => "Réponse eval2" }

      create :evenement_reponse, partie: partie2,
             donnees: { "question" => question_redaction.id, "reponse" => "" }

      create :evenement_reponse, partie: partie2,
             donnees: { "question" => question_redaction.id, "reponse" => nil }

      create :evenement_reponse, partie: partie2,
             donnees: { "question" => autre_question.id, "reponse" => "Autre réponse" }
    end

    it "retourne les réponses de rédaction groupées par évaluation" do
      evaluation_ids = [ evaluation1.id, evaluation2.id, evaluation3.id ]

      result = described_class.reponses_redaction_pour_evaluations(evaluation_ids)

      expect(result[evaluation1.id]).to contain_exactly("Première réponse", "Deuxième réponse")
      expect(result[evaluation2.id]).to contain_exactly("Réponse eval2")
      expect(result[evaluation3.id]).to be_nil
      expect(result.keys).to contain_exactly(evaluation1.id, evaluation2.id)
    end

    it "retourne un hash vide quand aucune évaluation ne correspond" do
      result = described_class.reponses_redaction_pour_evaluations([])

      expect(result).to eq({})
    end

    it "retourne un hash vide quand la question n'existe pas" do
      question_redaction.destroy!
      evaluation_ids = [ evaluation1.id, evaluation2.id ]

      result = described_class.reponses_redaction_pour_evaluations(evaluation_ids)

      expect(result).to eq({})
    end
  end
end
