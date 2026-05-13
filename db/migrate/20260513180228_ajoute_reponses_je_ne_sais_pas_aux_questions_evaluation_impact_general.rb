class AjouteReponsesJeNeSaisPasAuxQuestionsEvaluationImpactGeneral < ActiveRecord::Migration[7.2]
  REPONSES_JNSP = [
    { question: 'Q2PC01', nom_technique: 'Q2PC01R3' },
    { question: 'Q2PC02', nom_technique: 'Q2PC02R3' },
    { question: 'Q2PC03', nom_technique: 'Q2PC03R3' },
    { question: 'Q2AO01', nom_technique: 'Q2AO01R3' },
    { question: 'Q2AO02', nom_technique: 'Q2AO02R3' },
    { question: 'Q2AO03', nom_technique: 'Q2AO03R3' },
    { question: 'Q2AO04', nom_technique: 'Q2AO04R3' },
    { question: 'Q2SQ01', nom_technique: 'Q2SQ01R3' },
    { question: 'Q2SQ02', nom_technique: 'Q2SQ02R3' },
    { question: 'Q2SQ03', nom_technique: 'Q2SQ03R3' },
    { question: 'Q2SQ04', nom_technique: 'Q2SQ04R3' },
    { question: 'Q2SQ05', nom_technique: 'Q2SQ05R3' },
    { question: 'Q2SQ06', nom_technique: 'Q2SQ06R3' },
    { question: 'Q2SQ07', nom_technique: 'Q2SQ07R3' },
    { question: 'Q2MP01', nom_technique: 'Q2MP01R3' },
    { question: 'Q2MP02', nom_technique: 'Q2MP02R3' },
    { question: 'Q2MP03', nom_technique: 'Q2MP03R3' },
    { question: 'Q2MP04', nom_technique: 'Q2MP04R3' },
    { question: 'Q2MP05', nom_technique: 'Q2MP05R3' },
    { question: 'Q2MP06', nom_technique: 'Q2MP06R3' },
    { question: 'Q2MP07', nom_technique: 'Q2MP07R3' },
    { question: 'Q2MP08', nom_technique: 'Q2MP08R3' },
  ].freeze

  def up
    REPONSES_JNSP.each do |entry|
      question = Question.find_by(nom_technique: entry[:question])
      next unless question

      position = Choix.where(question_id: question.id).count + 1
      Choix.find_or_create_by(nom_technique: entry[:nom_technique], question_id: question.id) do |c|
        c.intitule = 'Je ne sais pas'
        c.type_choix = 'bon'
        c.position = position
      end
    end
  end

  def down
    REPONSES_JNSP.each do |entry|
      question = Question.find_by(nom_technique: entry[:question])
      next unless question

      Choix.find_by(nom_technique: entry[:nom_technique], question_id: question.id)&.destroy
    end
  end
end
