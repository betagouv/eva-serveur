class RattrapageMetacompetencesPourQuestions3 < ActiveRecord::Migration[7.2]
  def up
    data = {
      'N3Rrp1' => 'resolution_de_probleme',
      'N3Rrp2' => 'resolution_de_probleme',
    }
    data.each do |id, metacompetence|
      question = Question.find_by(nom_technique: id)
      if question
        question.update(metacompetence: metacompetence)
      else
        puts "Question with nom_technique '#{id}' not found."
      end
    end
  end

  def down; end
end
