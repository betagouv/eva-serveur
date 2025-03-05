class RenommeMetacompetencesPourEvenements < ActiveRecord::Migration[7.2]
  def up
    Evenement.where("donnees ->> 'question' IN (?)", ["N1Prn1", "N1Prn2"])
      .update_all("donnees = jsonb_set(donnees, '{metacompetence}', '\"reconnaitre_les_nombres\"')")

    Evenement.where("donnees ->> 'question' IN (?)", ["N2Ppl1", "N2Ppl2", "N2Rpl1", "N2Rpl2"])
      .update_all("donnees = jsonb_set(donnees, '{metacompetence}', '\"plannings_lecture\"')")

    Evenement.where("donnees ->> 'question' IN (?)", ["N2Ron1", "N2Ron2"])
      .update_all("donnees = jsonb_set(donnees, '{metacompetence}', '\"ordonner_nombres_decimaux\"')")
      
    Evenement.where("donnees ->> 'metacompetence' = ?", "unites_temps")
      .update_all("donnees = jsonb_set(donnees, '{metacompetence}', '\"unites_de_temps\"')")

    Evenement.where("donnees ->> 'question' IN (?)", ["N3Pps1", "N3Rps2"])
      .update_all("donnees = jsonb_set(donnees, '{metacompetence}', '\"surfaces\"')")
      
    Evenement.where("donnees ->> 'question' IN (?)", ["N3Pps2", "N3Rps1"])
      .update_all("donnees = jsonb_set(donnees, '{metacompetence}', '\"perimetres\"')")  
  end
end
