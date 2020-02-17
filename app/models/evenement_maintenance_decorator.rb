# frozen_string_literal: true

class EvenementMaintenanceDecorator < SimpleDelegator
  EVENEMENT = {
    NON_MOT: 'non-mot',
    REPONSE_NON_FRANCAIS: 'pasfrancais',
    REPONSE_FRANCAIS: 'francais',
    IDENTIFICATION: 'identificationMot',
    APPARITION_MOT: 'apparitionMot'
  }.freeze

  def type_non_mot
    donnees['type'] == EVENEMENT[:NON_MOT]
  end

  def type_mot_francais
    donnees['type'] != EVENEMENT[:NON_MOT]
  end

  def reponse_francais
    donnees['reponse'] == EVENEMENT[:REPONSE_FRANCAIS]
  end

  def reponse_non_francais
    donnees['reponse'] == EVENEMENT[:REPONSE_NON_FRANCAIS]
  end

  def type_non_mot_correct
    donnees['type'] == EVENEMENT[:NON_MOT] &&
      reponse_non_francais
  end

  def identification_mot
    nom == EVENEMENT[:IDENTIFICATION]
  end

  def apparition_non_mot
    nom == EVENEMENT[:APPARITION_MOT] &&
      type_non_mot
  end

  def apparition_ou_identification_non_mot
    apparition_non_mot || type_non_mot
  end

  def identification_non_mot_correcte
    identification_mot && type_non_mot_correct
  end
end
