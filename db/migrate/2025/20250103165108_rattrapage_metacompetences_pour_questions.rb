class RattrapageMetacompetencesPourQuestions < ActiveRecord::Migration[7.2]
  def up
    data = {
      'N1Pse1' => 'situation_dans_lespace',
      'N1Pse2' => 'situation_dans_lespace',
      'N1Pse3' => 'situation_dans_lespace',
      'N1Pse4' => 'situation_dans_lespace',
      'N1Prn1' => 'reconaitre_les_nombres',
      'N1Prn2' => 'reconaitre_les_nombres',
      'N1Pde1' => 'denombrement',
      'N1Pde2' => 'denombrement',
      'N1Pes1' => 'estimation',
      'N1Pes2' => 'estimation',
      'N1Pon1' => 'ordonner_nombres_entiers',
      'N1Pon2' => 'ordonner_nombres_entiers',
      'N1Poa1' => 'operations_addition',
      'N1Poa2' => 'operations_addition',
      'N1Pos1' => 'operations_soustraction',
      'N1Pos2' => 'operations_soustraction',
      'N1Pvn1' => 'vocabulaire_numeracie',
      'N1Pvn2' => 'vocabulaire_numeracie',
      'N1Pvn3' => 'vocabulaire_numeracie',
      'N1Pvn4' => 'vocabulaire_numeracie',
      'N2Plp1' => 'lecture_plan',
      'N2Plp2' => 'lecture_plan',
      'N2Ppe1' => 'perimetres',
      'N2Ppe2' => 'perimetres',
      'N2Psu1' => 'surfaces',
      'N2Psu2' => 'surfaces',
      'N2Pom1' => 'operations_multiplication',
      'N2Pom2' => 'operations_multiplication',
      'N2Pon1' => 'ordonner_nombres_decimaux',
      'N2Pon2' => 'ordonner_nombres_decimaux',
      'N2Pod1' => 'operations_division',
      'N2Pod2' => 'operations_division',
      'N2Put1' => 'unites_temps',
      'N2Put2' => 'unites_temps',
      'N2Prh1' => 'renseigner_horaires',
      'N2Prh2' => 'renseigner_horaires',
      'N2Ptg1' => 'tableaux_graphiques',
      'N2Ptg2' => 'tableaux_graphiques',
      'N2Ppl1' => 'plannings',
      'N2Ppl2' => 'plannings',
      'N3Ppl1' => 'plannings_calculs',
      'N3Ppl2' => 'plannings_calculs',
      'N3Put1' => 'unites_de_temps_conversions',
      'N3Put2' => 'unites_de_temps_conversions'
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
