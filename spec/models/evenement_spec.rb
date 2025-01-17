# frozen_string_literal: true

require 'rails_helper'

describe Evenement, type: :model do
  it { is_expected.to validate_presence_of :nom }
  it { is_expected.to validate_uniqueness_of(:position).scoped_to(:session_id) }
  it { is_expected.to validate_presence_of :date }
  it { is_expected.to validate_presence_of :session_id }
  it { is_expected.to allow_value(nil).for :donnees }

  it do
    expect(subject).to belong_to(:partie)
      .with_primary_key(:session_id)
      .with_foreign_key(:session_id)
  end

  describe '#fin_situation?' do
    it "retourne true quand le nom de l'évènement est 'finSituation'" do
      evenement = described_class.new nom: 'finSituation'
      expect(evenement.fin_situation?).to be true
    end

    it "retourne false quand le nom de l'évènement n'est pas 'finSituation'" do
      evenement = described_class.new nom: 'autre'
      expect(evenement.fin_situation?).to be false
    end
  end

  describe '.groupees_par_questions' do
    let(:session_id) { 'session_id' }
    let(:partie) { create(:partie, session_id: session_id) }

    let!(:evenement) do
      create(:evenement, partie: partie, session_id: session_id,
                         donnees: { 'question' => question_evenement },
                         date: 10.minutes.ago, position: 3)
    end
    let!(:autre_evenement) do
      create(:evenement, partie: partie, session_id: session_id,
                         donnees: { 'question' => autre_question_evenement },
                         date: 10.minutes.ago, position: 2)
    end

    context 'quand une question a deux evenements' do
      let(:question_evenement) { 'Question 1' }
      let(:autre_question_evenement) { 'Question 1' }

      it 'regroupe les evenements' do
        result = described_class.groupees_par_questions

        expect(result.keys).to contain_exactly('Question 1')
        expect(result['Question 1'].size).to eq(2)
        expect(result['Question 1']).to contain_exactly(
          have_attributes(question: 'Question 1', date: evenement.date, position: 3),
          have_attributes(question: 'Question 1', date: autre_evenement.date, position: 2)
        )
      end

      it 'ordonne les evenements par position' do
        result = described_class.groupees_par_questions

        expect(result['Question 1'][0]).to have_attributes(
          question: 'Question 1', date: autre_evenement.date, position: 2
        )

        expect(result['Question 1'][1]).to have_attributes(
          question: 'Question 1', date: evenement.date, position: 3
        )
      end
    end

    context "quand une question a qu'un evenement" do
      let(:question_evenement) { 'Question 1' }
      let(:autre_question_evenement) { 'Question 2' }

      it 'regroupe les evenements seuls' do
        result = described_class.groupees_par_questions

        expect(result.keys).to contain_exactly('Question 1', 'Question 2')
        expect(result['Question 1'].size).to eq(1)
        expect(result['Question 1']).to contain_exactly(
          have_attributes(question: 'Question 1', date: evenement.date, position: 3)
        )
        expect(result['Question 2'].size).to eq(1)
        expect(result['Question 2']).to contain_exactly(
          have_attributes(question: 'Question 2', date: autre_evenement.date, position: 2)
        )
      end
    end
  end

  describe '#recupere_evenement_affichage_question_qcm' do
    subject { described_class.new(partie: partie, donnees: donnees) }

    let(:donnees) { { 'question' => 'Question 1' } }
    let(:partie) { create :partie }

    let!(:evenement) do
      create :evenement, nom: 'affichageQuestionQCM', donnees: donnees, partie: partie
    end

    it "retourne l'evenement affichageQuestionQCM de l'evenement reponse" do
      result = subject.recupere_evenement_affichage_question_qcm
      expect(result).to eq(evenement)
    end

    it "ne retourne pas d'evenement affichageQuestionQCM si la question ne correspond pas" do
      subject.donnees = { 'question' => 'Non-existent question' }
      result = subject.recupere_evenement_affichage_question_qcm
      expect(result).to be_nil
    end
  end
end
