class RenomeQuestionRedactionNoteEnQuestionSaisie < ActiveRecord::Migration[7.0]
  def up
    ActiveRecord::Base.connection.execute(<<-EOQ)
      UPDATE  questions
      SET     type = 'QuestionSaisie'
      WHERE   type = 'QuestionRedactionNote'
    EOQ
  end

  def down
    ActiveRecord::Base.connection.execute(<<-EOQ)
      UPDATE  questions
      SET     type = 'QuestionRedactionNote'
      WHERE   type = 'QuestionSaisie'
    EOQ
  end
end
