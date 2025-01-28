# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EvenementQuestion, type: :model do
  let(:question) { build(:question, metacompetence: 'CLEA') }
  let(:question_2) { build(:question, metacompetence: 'CLEA') }
  let(:evenement) do
    build(:evenement, donnees: { 'score' => 1, 'scoreMax' => 2, 'succes' => true })
  end
  let(:evenement_2) { build(:evenement, donnees: {}) }
  let(:evenement_question) { described_class.new(question: question, evenement: evenement) }
  let(:evenement_question_2) { described_class.new(question: question_2, evenement: evenement_2) }
  let(:evenements_questions) { [evenement_question] }

  describe '#score' do
    it 'retourne le score de l\'événement' do
      expect(evenement_question.score).to eq(1)
    end
  end

  describe '#score_max' do
    it 'retourne le score maximum de l\'événement' do
      expect(evenement_question.score_max).to eq(2)
    end
  end

  describe '#succes' do
    it 'retourne le succès de l\'événement' do
      expect(evenement_question.succes).to be true
    end
  end

  describe '#reponse' do
    it 'retourne la réponse de l\'événement' do
      evenement.donnees['reponseIntitule'] = 'Réponse A'
      expect(evenement_question.reponse).to eq('Réponse A')
    end
  end

  describe '#a_ete_repondue?' do
    it 'retourne true si l\'événement a été répondu' do
      allow(evenement).to receive(:persisted?).and_return(true)
      expect(evenement_question.a_ete_repondue?).to be true
    end
  end

  describe '#interaction' do
    it 'retourne l\'interaction de la question' do
      expect(evenement_question.interaction).to eq(question.interaction)
    end
  end

  describe '#nom_technique' do
    it 'retourne le nom technique de la question' do
      expect(evenement_question.nom_technique).to eq(question.nom_technique)
    end
  end

  describe '#pris_en_compte_pour_calcul_score_clea?' do
    it 'retourne true si la question est prise en compte pour le calcul du score CLEA' do
      expect(evenement_question.pris_en_compte_pour_calcul_score_clea?(evenements_questions)).to be true
    end

    it 'retourne false si la question n\'est pas prise en compte pour le calcul du score CLEA' do
      expect(evenement_question_2.pris_en_compte_pour_calcul_score_clea?(evenements_questions)).to be false
    end
  end

  describe '.pourcentage_pour_groupe' do
    let(:evenements_questions) { [evenement_question, evenement_question] }

    it 'calcul le pourcentage de réussite pour un groupe d\'événements' do
      expect(described_class.pourcentage_pour_groupe(evenements_questions)).to eq(50)
    end
  end

  describe '.score_max_pour_groupe' do
    it 'retourne le score maximum pour un groupe d\'événements' do
      expect(described_class.score_max_pour_groupe(evenements_questions)).to eq(2)
    end
  end

  describe '.score_pour_groupe' do
    it 'retourne le score pour un groupe d\'événements' do
      expect(described_class.score_pour_groupe(evenements_questions)).to eq(1)
    end
  end

  describe '.filtre_pris_en_compte' do
    it 'retourne les événements pris en compte pour le calcul du score CLEA' do
      expect(described_class.filtre_pris_en_compte(evenements_questions,
                                                   evenements_questions)).to eq(evenements_questions)
    end
  end
end
