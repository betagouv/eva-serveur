require 'rails_helper'

describe Questionnaire, type: :model do
  it { is_expected.to have_many(:questionnaires_questions).dependent(:destroy) }

  it { is_expected.to validate_presence_of :libelle }
  it { is_expected.to validate_presence_of :nom_technique }
  it { is_expected.to validate_uniqueness_of :nom_technique }

  context 'avec un enregistrement soft-supprimé' do
    before do
      create(:questionnaire, nom_technique: 'unique_nom_technique', deleted_at: Time.current)
    end

    it "permet la création d'un nouvel enregistrement avec le même nom_technique" do
      new_questionnaire = build(:questionnaire, nom_technique: 'unique_nom_technique')
      expect(new_questionnaire).to be_valid
    end
  end

  describe '#livraison_sans_redaction?' do
    context 'quand le questionnaire est livraison sans rédaction' do
      let(:questionnaire) do
        described_class.new nom_technique: Questionnaire::LIVRAISON_SANS_REDACTION
      end

      it { expect(questionnaire.livraison_sans_redaction?).to be(true) }
    end

    context "quand le questionnaire n'est pas livraison sans rédaction" do
      let(:questionnaire) do
        described_class.new nom_technique: Questionnaire::LIVRAISON_AVEC_REDACTION
      end

      it { expect(questionnaire.livraison_sans_redaction?).to be(false) }
    end
  end

  describe '#questions_par_type' do
    let(:questionnaire) { create :questionnaire }
    let(:question_clic_dans_image) { create :question_clic_dans_image }
    let(:question_qcm) { create :question_qcm }

    before do
      create :questionnaire_question, questionnaire_id: questionnaire.id,
                                      question_id: question_clic_dans_image.id
      create :questionnaire_question, questionnaire_id: questionnaire.id,
                                      question_id: question_qcm.id
    end

    it do
      expect(questionnaire.questions_par_type).to eq(
        'QuestionClicDansImage' => [ question_clic_dans_image ],
        'QuestionQcm' => [ question_qcm ]
      )
    end
  end

  describe '#nom_fichier_export' do
    let(:questionnaire) { create :questionnaire, nom_technique: 'nom_technique' }

    it "retourn un fichier horodaté avec l'identifiant" do
      Timecop.freeze(Time.zone.local(2025, 2, 28, 1, 2, 3)) do
        expect(questionnaire.nom_fichier_export)
          .to eq '20250228010203-export-questionnaire-nom_technique.zip'
      end
    end
  end
end
