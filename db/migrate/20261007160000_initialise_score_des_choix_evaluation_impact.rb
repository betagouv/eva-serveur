class InitialiseScoreDesChoixEvaluationImpact < ActiveRecord::Migration[8.0]
  SCORES = {
    "Q2PC01" => {
      "Q2PC01R1" => { "cout" => 3, "strategies" => 0, "numerique" => 0 },
      "Q2PC01R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2PC01R3" => { "cout" => 0, "strategies" => 0, "numerique" => 0 }
    },
    "Q2PC02" => {
      "Q2PC02R1" => { "cout" => 4, "strategies" => 3, "numerique" => 0 },
      "Q2PC02R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2PC02R3" => { "cout" => 4, "strategies" => 3, "numerique" => 0 }
    },
    "Q2PC03" => {
      "Q2PC03R1" => { "cout" => 1, "strategies" => 4, "numerique" => 2 },
      "Q2PC03R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2PC03R3" => { "cout" => 1, "strategies" => 4, "numerique" => 2 }
    },
    "Q2AO01" => {
      "Q2AO01R1" => { "cout" => 0, "strategies" => 3, "numerique" => 0 },
      "Q2AO01R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2AO01R3" => { "cout" => 0, "strategies" => 0, "numerique" => 0 }
    },
    "Q2AO02" => {
      "Q2AO02R1" => { "cout" => 2, "strategies" => 0, "numerique" => 4 },
      "Q2AO02R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2AO02R3" => { "cout" => 2, "strategies" => 0, "numerique" => 4 }
    },
    "Q2AO03" => {
      "Q2AO03R1" => { "cout" => 4, "strategies" => 0, "numerique" => 3 },
      "Q2AO03R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2AO03R3" => { "cout" => 4, "strategies" => 0, "numerique" => 3 }
    },
    "Q2AO04" => {
      "Q2AO04R1" => { "cout" => 4, "strategies" => 0, "numerique" => 2 },
      "Q2AO04R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2AO04R3" => { "cout" => 4, "strategies" => 0, "numerique" => 2 }
    },
    "Q2SQ01" => {
      "Q2SQ01R1" => { "cout" => 2, "strategies" => 2, "numerique" => 0 },
      "Q2SQ01R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2SQ01R3" => { "cout" => 0, "strategies" => 0, "numerique" => 0 }
    },
    "Q2SQ02" => {
      "Q2SQ02R1" => { "cout" => 1, "strategies" => 4, "numerique" => 2 },
      "Q2SQ02R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2SQ02R3" => { "cout" => 1, "strategies" => 4, "numerique" => 2 }
    },
    "Q2SQ03" => {
      "Q2SQ03R1" => { "cout" => 2, "strategies" => 0, "numerique" => 2 },
      "Q2SQ03R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2SQ03R3" => { "cout" => 0, "strategies" => 0, "numerique" => 0 }
    },
    "Q2SQ04" => {
      "Q2SQ04R1" => { "cout" => 2, "strategies" => 3, "numerique" => 2 },
      "Q2SQ04R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2SQ04R3" => { "cout" => 2, "strategies" => 3, "numerique" => 2 }
    },
    "Q2SQ05" => {
      "Q2SQ05R1" => { "cout" => 4, "strategies" => 0, "numerique" => 0 },
      "Q2SQ05R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2SQ05R3" => { "cout" => 0, "strategies" => 0, "numerique" => 0 }
    },
    "Q2SQ06" => {
      "Q2SQ06R1" => { "cout" => 2, "strategies" => 0, "numerique" => 4 },
      "Q2SQ06R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2SQ06R3" => { "cout" => 2, "strategies" => 0, "numerique" => 4 }
    },
    "Q2SQ07" => {
      "Q2SQ07R1" => { "cout" => 4, "strategies" => 0, "numerique" => 2 },
      "Q2SQ07R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2SQ07R3" => { "cout" => 4, "strategies" => 0, "numerique" => 2 }
    },
    "Q2MP01" => {
      "Q2MP01R1" => { "cout" => 3, "strategies" => 4, "numerique" => 2 },
      "Q2MP01R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2MP01R3" => { "cout" => 3, "strategies" => 4, "numerique" => 2 }
    },
    "Q2MP02" => {
      "Q2MP02R1" => { "cout" => 2, "strategies" => 0, "numerique" => 0 },
      "Q2MP02R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2MP02R3" => { "cout" => 0, "strategies" => 0, "numerique" => 0 }
    },
    "Q2MP03" => {
      "Q2MP03R1" => { "cout" => 4, "strategies" => 0, "numerique" => 2 },
      "Q2MP03R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2MP03R3" => { "cout" => 4, "strategies" => 0, "numerique" => 2 }
    },
    "Q2MP04" => {
      "Q2MP04R1" => { "cout" => 1, "strategies" => 0, "numerique" => 4 },
      "Q2MP04R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2MP04R3" => { "cout" => 0, "strategies" => 0, "numerique" => 0 }
    },
    "Q2MP05" => {
      "Q2MP05R1" => { "cout" => 2, "strategies" => 2, "numerique" => 0 },
      "Q2MP05R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2MP05R3" => { "cout" => 0, "strategies" => 0, "numerique" => 0 }
    },
    "Q2MP06" => {
      "Q2MP06R1" => { "cout" => 3, "strategies" => 3, "numerique" => 3 },
      "Q2MP06R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2MP06R3" => { "cout" => 3, "strategies" => 3, "numerique" => 3 }
    },
    "Q2MP07" => {
      "Q2MP07R1" => { "cout" => 1, "strategies" => 4, "numerique" => 2 },
      "Q2MP07R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2MP07R3" => { "cout" => 1, "strategies" => 4, "numerique" => 2 }
    },
    "Q2MP08" => {
      "Q2MP08R1" => { "cout" => 1, "strategies" => 3, "numerique" => 2 },
      "Q2MP08R2" => { "cout" => 0, "strategies" => 0, "numerique" => 0 },
      "Q2MP08R3" => { "cout" => 1, "strategies" => 3, "numerique" => 2 }
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
