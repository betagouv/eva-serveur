require 'rails_helper'

describe MiseEnAction::Questionnaire, type: :model do
  describe '#recupere_question_reponses' do
    context 'quand le nom est remediation' do
      it 'récupére la question et les réponses associées' do
        question = 'Vers quel dispositif de remédiation cette personne a-t-elle été orientée ?'
        questionnaire = described_class.new(:remediation)
        expect(questionnaire.question).to eq(question)
        expect(questionnaire.reponses.values).to eq(%w[formation_competences_de_base
                                                       formation_metier
                                                       dispositif_remobilisation
                                                       levee_freins_peripheriques])
      end
    end

    context 'quand le nom est difficulte' do
      it 'récupére la question et les réponses associées' do
        question = 'Quelle difficulté avez-vous rencontré ?'
        questionnaire = described_class.new(:difficulte)
        expect(questionnaire.question).to eq(question)
        expect(questionnaire.reponses.values).to eq(%w[aucune_offre_formation
                                                       offre_formation_inaccessible
                                                       freins_peripheriques
                                                       accompagnement_necessaire])
      end
    end
  end
end
