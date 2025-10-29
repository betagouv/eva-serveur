class MigreScoreEtMetacompetence < ActiveRecord::Migration[7.2]
  METACOMPETENCES = {
    situation_dans_lespace: ['N1Pse1', 'N1Pse2', 'N1Pse3', 'N1Pse4'],
    reconaitre_les_nombres: ['N1Prn1', 'N1Prn2'],
    denombrement: ['N1Pde1', 'N1Pde2'],
    estimation: ['N1Pes1', 'N1Pes2'],
    ordonner_nombres_entiers: ['N1Pon1', 'N1Pon2'],
    operations_addition: ['N1Poa1', 'N1Poa2'],
    operations_soustraction: ['N1Pos1', 'N1Pos2'],
    vocabulaire_numeracie: ['N1Pvn1', 'N1Pvn2', 'N1Pvn3', 'N1Pvn4'],
    lecture_plan: ['N2Plp1', 'N2Plp2'],
    perimetres: ['N2Ppe1', 'N2Ppe2'],
    surfaces: ['N2Psu1', 'N2Psu2'],
    operations_multiplication: ['N2Pom1', 'N2Pom2'],
    ordonner_nombres_decimaux: ['N2Pon1', 'N2Pon2'],
    operations_division: ['N2Pod1', 'N2Pod2'],
    unites_temps: ['N2Put1', 'N2Put2'],
    renseigner_horaires: ['N2Prh1', 'N2Prh2'],
    tableaux_graphiques: ['N2Ptg1', 'N2Ptg2'],
    plannings: ['N2Ppl1', 'N2Ppl2'],
    plannings_calculs: ['N3Ppl1', 'N3Ppl2'],
    unites_de_temps_conversions: ['N3Put1', 'N3Put2'],
    unites_de_mesure: ['N3Pum1', 'N3Pum2', 'N3Pum3', 'N3Pum4'],
    instruments_de_mesure: ['N3Pim1', 'N3Pim2', 'N3Pim3', 'N3Pim4'],
    pourcentages: ['N3Ppo1', 'N3Ppo2'],
    proportionnalite: ['N3Ppr1', 'N3Ppr2'],
    perimetres_surfaces: ['N3Pps1', 'N3Pps2'],
    volumes: ['N3Pvo1', 'N3Pvo2'],
    resolution_de_probleme: ['N3Prp1', 'N3Prp2']
  }.freeze;

  def up
    demi_scores = ['N1Pse1', 'N1Pse2', 'N1Pse3', 'N1Pse4', 'N1Pvn1', 'N1Pvn2', 'N1Pvn3', 'N1Pvn4']
    numeratie = Questionnaire.find_or_create_by(nom_technique: 'numeratie_2024')
    numeratie.questions.each do |question|
      question.score = demi_scores.include?(question.nom_technique) ? 0.5 : 1
      question.metacompetence = METACOMPETENCES.find { |_, noms_techniques| noms_techniques.include?(question.nom_technique) }&.first
      question.save!
    end
  end
end
