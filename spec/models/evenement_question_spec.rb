# frozen_string_literal: true

require 'rails_helper'

describe EvenementQuestion, type: :model do
  describe '.prises_en_compte_pour_calcul_score_clea(questions_repondues)' do
    let(:question_n1) { build(:question, :numeratie_niveau1, score: 1) }
    let(:question_rattrapage_n1) { build(:question, :numeratie_niveau1_rattrapage, score: 1) }

    let(:evenements_questions) { [] }

    let(:resultat) do
      described_class.prises_en_compte_pour_calcul_score_clea(evenements_questions)
    end

    context 'quand les questions sont pour la litteratie' do
      it "retourne l'ensemble des questions" do
        expect(resultat).to eq evenements_questions
      end
    end

    context "quand il n'y a pas de rattrapage dans les questions répondues" do
      let(:evenement_question_n1) do
        described_class.new(question: question_n1,
                            evenement: build(:evenement,
                                             donnees: { score: 1,
                                                        question: question_n1.nom_technique }))
      end
      let(:evenement_question_n1_rattrapage) do
        described_class.new(question: question_rattrapage_n1)
      end
      let(:evenements_questions) { [evenement_question_n1, evenement_question_n1_rattrapage] }

      it 'ne retourne pas les questions de rattrapage' do
        expect(resultat).not_to include(evenement_question_n1_rattrapage)
        expect(evenements_questions.size).to eq 2
      end
    end

    context 'quand il y a une question principale échouée' do
      let(:evenement_question_n1) do
        described_class.new(question: question_n1,
                            evenement: build(:evenement,
                                             donnees: { score: 0,
                                                        question: question_n1.nom_technique }))
      end
      let(:evenement_question_n1_rattrapage) do
        described_class.new(question: question_rattrapage_n1)
      end
      let(:evenements_questions) { [evenement_question_n1, evenement_question_n1_rattrapage] }

      it 'retourne les questions de rattrapage N1Rrn' do
        expect(resultat).to include(evenement_question_n1_rattrapage)
      end
    end
  end

  describe '.pour_code_clea(evenements_questions, code)' do
    let(:code) { '2.1' }
    let(:sous_code) { '2.1.1' }

    let(:metacompetence_numeratie) do
      Metacompetence::CORRESPONDANCES_CODECLEA[code][sous_code].first
    end
    let!(:question_attendu) { build(:question, metacompetence: metacompetence_numeratie) }
    let(:evenement_question_attendu) { described_class.new(question: question_attendu) }

    let!(:autre_metacompetence) { Metacompetence::CORRESPONDANCES_CODECLEA[code]['2.1.2'].first }
    let!(:autre_question) { build(:question, metacompetence: autre_metacompetence) }
    let(:evenement_question_autre) { described_class.new(question: autre_question) }

    let(:evenements_questions) { [evenement_question_attendu, evenement_question_autre] }

    it 'retourne les questions du sous_code' do
      expect(described_class.pour_code_clea(evenements_questions, sous_code)).to(
        eq([evenement_question_attendu])
      )
    end

    it 'retourne les questions du code' do
      expect(described_class.pour_code_clea(evenements_questions,
                                            code)).to eq [evenement_question_attendu,
                                                          evenement_question_autre]
    end
  end
end
