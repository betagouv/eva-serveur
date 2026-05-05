class RattrapageMetacompetencesPourQuestions2 < ActiveRecord::Migration[7.2]
  def up
    data = {
      'N1Rrn1' => 'reconnaitre_les_nombres',
      'N1Rrn2' => 'reconnaitre_les_nombres',
      'N1Rde1' => 'denombrement',
      'N1Rde2' => 'denombrement',
      'N1Res1' => 'estimation',
      'N1Res2' => 'estimation',
      'N1Ron1' => 'ordonner_nombres_entiers',
      'N1Ron2' => 'ordonner_nombres_entiers',
      'N1Roa1' => 'operations_addition',
      'N1Roa2' => 'operations_addition',
      'N1Ros1' => 'operations_soustraction',
      'N1Ros2' => 'operations_soustraction',
      'N2Rlp1' => 'lecture_plan',
      'N2Rlp2' => 'lecture_plan',
      'N2Rpe1' => 'perimetres',
      'N2Rpe2' => 'perimetres',
      'N2Rsu1' => 'surfaces',
      'N2Rsu2' => 'surfaces',
      'N2Rom1' => 'operations_multiplication',
      'N2Rom2' => 'operations_multiplication',
      'N2Ron1' => 'operations_nombres_entiers',
      'N2Ron2' => 'operations_nombres_entiers',
      'N2Rod1' => 'operations_division',
      'N2Rod2' => 'operations_division',
      'N2Rut1' => 'unites_temps',
      'N2Rut2' => 'unites_temps',
      'N2Rrh1' => 'renseigner_horaires',
      'N2Rrh2' => 'renseigner_horaires',
      'N2Rtg1' => 'tableaux_graphiques',
      'N2Rtg2' => 'tableaux_graphiques',
      'N2Rpl1' => 'plannings',
      'N2Rpl2' => 'plannings',
      'N3Rpl1' => 'plannings_calculs',
      'N3Rpl2' => 'plannings_calculs',
      'N3Rut1' => 'unites_de_temps_conversions',
      'N3Rut2' => 'unites_de_temps_conversions',
      'N3Rpo1' => 'pourcentages',
      'N3Rpo2' => 'pourcentages',
      'N3Rpr1' => 'proportionnalite',
      'N3Rpr2' => 'proportionnalite',
      'N3Rps1' => 'perimetres_surfaces',
      'N3Rps2' => 'perimetres_surfaces',
      'N3Rvo1' => 'volumes',
      'N3Rvo2' => 'volumes'
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
