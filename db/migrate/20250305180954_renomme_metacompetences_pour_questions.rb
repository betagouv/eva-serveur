class RenommeMetacompetencesPourQuestions < ActiveRecord::Migration[7.2]
  def up
    Question.where(metacompetence: "reconaitre_les_nombres").update_all(metacompetence: "reconnaitre_les_nombres")
    Question.where(metacompetence: "plannings").update_all(metacompetence: "plannings_lecture")
    Question.where(metacompetence: "ordonner_nombres_entiers").update_all(metacompetence: "")
    Question.where(metacompetence: "unites_temps").update_all(metacompetence: "unites_de_temps")
    Question.where(metacompetence: "perimetres_surfaces").update_all(metacompetence: "perimetres")

    Question.where(nom_technique: %w[N2Ppl1 N2Ppl2 N2Rpl1 N2Rpl2]).update_all(metacompetence: "plannings_lecture")
    Question.where(nom_technique: %w[N2Ron1 N2Ron2]).update_all(metacompetence: "ordonner_nombres_decimaux")
    Question.where(nom_technique: %w[N3Pps1 N3Rps2]).update_all(metacompetence: "surfaces")
    Question.where(nom_technique: %w[N3Pps2 N3Rps1]).update_all(metacompetence: "perimetres")
  end

  def down; end
end
