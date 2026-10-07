class InitialiseScoreDesChoixDiagnosticRisques < ActiveRecord::Migration[8.0]
  SCORES = {
    "Q1IC01" => {
      "Q1IC01R01" => { "risques" => 0 },
      "Q1IC01R02" => { "risques" => 0 },
      "Q1IC01R03" => { "risques" => 0 },
      "Q1IC01R04" => { "risques" => 0 },
      "Q1IC01R05" => { "risques" => 0 }
    },
    "Q1IC02" => {
      "Q1IC02R01" => { "risques" => 2 },
      "Q1IC02R02" => { "risques" => 0 },
      "Q1IC02R03" => { "risques" => 1 },
      "Q1IC02R04" => { "risques" => 1 }
    },
    "Q1IC03" => {
      "Q1IC03R01" => { "risques" => 2 },
      "Q1IC03R02" => { "risques" => 2 },
      "Q1IC03R03" => { "risques" => 2 },
      "Q1IC03R04" => { "risques" => 0 },
      "Q1IC03R05" => { "risques" => 2 },
      "Q1IC03R06" => { "risques" => 1 },
      "Q1IC03R07" => { "risques" => 0 },
      "Q1IC03R08" => { "risques" => 1 },
      "Q1IC03R09" => { "risques" => 1 },
      "Q1IC03R10" => { "risques" => 1 },
      "Q1IC03R11" => { "risques" => 1 },
      "Q1IC03R12" => { "risques" => 2 },
      "Q1IC03R13" => { "risques" => 2 },
      "Q1IC03R14" => { "risques" => 1 },
      "Q1IC03R15" => { "risques" => 1 },
      "Q1IC03R16" => { "risques" => 1 },
      "Q1IC03R17" => { "risques" => 0 },
      "Q1IC03R18" => { "risques" => 2 }
    },
    "Q1IC05" => {
      "Q1IC05R01" => { "risques" => 1 },
      "Q1IC05R02" => { "risques" => 0 },
      "Q1IC05R03" => { "risques" => 1 },
      "Q1IC05R04" => { "risques" => 1 },
      "Q1IC05R05" => { "risques" => 1 }
    },
    "Q1PC01" => {
      "Q1PC01R01" => { "risques" => 2 },
      "Q1PC01R02" => { "risques" => 2 },
      "Q1PC01R03" => { "risques" => 0 },
      "Q1PC01R04" => { "risques" => 0 },
      "Q1PC01R05" => { "risques" => 0 }
    },
    "Q1PC02" => {
      "Q1PC02R01" => { "risques" => 3 },
      "Q1PC02R02" => { "risques" => 2 },
      "Q1PC02R03" => { "risques" => 1 },
      "Q1PC02R04" => { "risques" => 0 },
      "Q1PC02R05" => { "risques" => 0 },
      "Q1PC02R06" => { "risques" => 0 }
    },
    "Q1PC03" => {
      "Q1PC03R01" => { "risques" => 3 },
      "Q1PC03R02" => { "risques" => 2 },
      "Q1PC03R03" => { "risques" => 1 },
      "Q1PC03R04" => { "risques" => 0 },
      "Q1PC03R05" => { "risques" => 1 }
    },
    "Q1GC01" => {
      "Q1GC01R01" => { "risques" => 0 },
      "Q1GC01R02" => { "risques" => 1 },
      "Q1GC01R03" => { "risques" => 2 },
      "Q1GC01R04" => { "risques" => 0 }
    },
    "Q1GC02" => {
      "Q1GC02R01" => { "risques" => 3 },
      "Q1GC02R02" => { "risques" => 2 },
      "Q1GC02R03" => { "risques" => 1 },
      "Q1GC02R04" => { "risques" => 0 },
      "Q1GC02R05" => { "risques" => 1 }
    },
    "Q1GC03" => {
      "Q1GC03R01" => { "risques" => 2 },
      "Q1GC03R02" => { "risques" => 0 },
      "Q1GC03R03" => { "risques" => 2 }
    },
    "Q1GC04" => {
      "Q1GC04R01" => { "risques" => 2 },
      "Q1GC04R02" => { "risques" => 0 },
      "Q1GC04R03" => { "risques" => 2 }
    },
    "Q1GC05" => {
      "Q1GC05R01" => { "risques" => 2 },
      "Q1GC05R02" => { "risques" => 1 },
      "Q1GC05R03" => { "risques" => 1 },
      "Q1GC05R04" => { "risques" => 0 },
      "Q1GC05R05" => { "risques" => 2 }
    },
    "Q1GC06" => {
      "Q1GC06R01" => { "risques" => 0 },
      "Q1GC06R02" => { "risques" => 0 },
      "Q1GC06R03" => { "risques" => 0 },
      "Q1GC06R04" => { "risques" => 0 }
    },
    "Q1PR01" => {
      "Q1PR01R01" => { "risques" => 3 },
      "Q1PR01R02" => { "risques" => 1 },
      "Q1PR01R03" => { "risques" => 0 },
      "Q1PR01R04" => { "risques" => 2 }
    },
    "Q1PR02" => {
      "Q1PR02R01" => { "risques" => 3 },
      "Q1PR02R02" => { "risques" => 1 },
      "Q1PR02R03" => { "risques" => 0 },
      "Q1PR02R04" => { "risques" => 2 }
    },
    "Q1TO01" => {
      "Q1TO01R01" => { "risques" => 3 },
      "Q1TO01R02" => { "risques" => 1 },
      "Q1TO01R03" => { "risques" => 0 },
      "Q1TO01R04" => { "risques" => 2 }
    },
    "Q1TO02" => {
      "Q1TO02R01" => { "risques" => 0 },
      "Q1TO02R02" => { "risques" => 0 },
      "Q1TO02R03" => { "risques" => 0 },
      "Q1TO02R04" => { "risques" => 0 }
    },
    "Q1TO03" => {
      "Q1TO03R01" => { "risques" => 0 },
      "Q1TO03R02" => { "risques" => 0 },
      "Q1TO03R03" => { "risques" => 0 }
    },
    "Q1TO04" => {
      "Q1TO04R01" => { "risques" => 0 },
      "Q1TO04R02" => { "risques" => 0 },
      "Q1TO04R03" => { "risques" => 0 }
    }
  }.freeze

  def up
    SCORES.each do |nom_technique_question, scores|
      question = Question.find_by(nom_technique: nom_technique_question)
      next unless question

      scores.each do |nom_technique_choix, score|
        Choix.where(question_id: question.id, nom_technique: nom_technique_choix)
             .update_all(score: score)
      end
    end
  end

  def down
    question_ids = Question.where(nom_technique: SCORES.keys).select(:id)
    Choix.where(question_id: question_ids).update_all(score: nil)
  end
end
