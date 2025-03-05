class MigreMetacompetencePourQuestions < ActiveRecord::Migration[7.2]
  METACOMPETENCES = [
    "numeratie",
    "ccf",
    "syntaxe-orthographe",
    "operations_addition",
    "operations_soustraction",
    "operations_multiplication",
    "operations_division",
    "denombrement",
    "ordonner_nombres_entiers",
    "ordonner_nombres_decimaux",
    "operations_nombres_entiers",
    "estimation",
    "proportionnalite",
    "resolution_de_probleme",
    "pourcentages",
    "unites_temps",
    "unites_de_temps_conversions",
    "plannings",
    "plannings_calculs",
    "renseigner_horaires",
    "unites_de_mesure",
    "instruments_de_mesure",
    "tableaux_graphiques",
    "surfaces",
    "perimetres",
    "perimetres_surfaces",
    "volumes",
    "lecture_plan",
    "situation_dans_lespace",
    "reconnaitre_les_nombres",
    "reconaitre_les_nombres",
    "vocabulaire_numeracie"
  ]

  def up
    METACOMPETENCES.each_with_index do |metacompetence, index|
      Question.where(metacompetence: index).update_all(new_metacompetence: metacompetence)
    end
  end

  def down; end
end
