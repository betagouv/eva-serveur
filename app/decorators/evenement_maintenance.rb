class EvenementMaintenance < SimpleDelegator
  EVENEMENT = {
    NON_MOT: "non-mot",
    REPONSE_NON_FRANCAIS: "pasfrancais",
    REPONSE_FRANCAIS: "francais",
    IDENTIFICATION: "identificationMot",
    APPARITION_MOT: "apparitionMot"
  }.freeze

  def type_non_mot?
    donnees["type"] == EVENEMENT[:NON_MOT]
  end

  def type_mot_francais?
    donnees["type"].present? && donnees["type"] != EVENEMENT[:NON_MOT]
  end

  def reponse_francais?
    donnees["reponse"] == EVENEMENT[:REPONSE_FRANCAIS]
  end

  def reponse_non_francais?
    donnees["reponse"] == EVENEMENT[:REPONSE_NON_FRANCAIS]
  end

  def identification_non_mot_correct?
    type_non_mot? && reponse_non_francais?
  end

  def identification_non_mot_incorrect?
    type_non_mot? && reponse_francais?
  end

  def identification_mot_francais_correct?
    type_mot_francais? && reponse_francais?
  end

  def identification_mot_francais_incorrect?
    type_mot_francais? && reponse_non_francais?
  end

  def identification_mot?
    nom == EVENEMENT[:IDENTIFICATION]
  end

  def non_reponse?
    donnees["reponse"].nil? && identification_mot?
  end
end
