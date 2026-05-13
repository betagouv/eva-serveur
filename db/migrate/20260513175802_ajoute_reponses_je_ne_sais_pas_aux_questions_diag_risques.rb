class AjouteReponsesJeNeSaisPasAuxQuestionsDiagRisques < ActiveRecord::Migration[7.2]
  REPONSES_JNSP = [
    { question: 'Q1IC01', nom_technique: 'Q1IC01R05' },
    { question: 'Q1IC02', nom_technique: 'Q1IC02R04' },
    { question: 'Q1IC03', nom_technique: 'Q1IC03R018' },
    { question: 'Q1IC05', nom_technique: 'Q1IC05R05' },
    { question: 'Q1PC01', nom_technique: 'Q1PC01R05' },
    { question: 'Q1PC02', nom_technique: 'Q1PC02R06' },
    { question: 'Q1PC03', nom_technique: 'Q1PC03R05' },
    { question: 'Q1GC01', nom_technique: 'Q1GC01R04' },
    { question: 'Q1GC02', nom_technique: 'Q1GC02R05' },
    { question: 'Q1GC03', nom_technique: 'Q1GC03R03' },
    { question: 'Q1GC04', nom_technique: 'Q1GC04R03' },
    { question: 'Q1GC05', nom_technique: 'Q1GC05R05' },
    { question: 'Q1GC06', nom_technique: 'Q1GC06R04' },
    { question: 'Q1PR01', nom_technique: 'Q1PR01R04' },
    { question: 'Q1PR02', nom_technique: 'Q1PR02R04' },
    { question: 'Q1TO01', nom_technique: 'Q1TO01R04' },
    { question: 'Q1TO02', nom_technique: 'Q1TO02R04' },
    { question: 'Q1TO03', nom_technique: 'Q1TO03R03' },
    { question: 'Q1TO04', nom_technique: 'Q1TO04R03' },
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
