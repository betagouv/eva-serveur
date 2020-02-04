# frozen_string_literal: true

class EvenementMaintenanceDecorator < SimpleDelegator
  EVENEMENT = {
    NON_MOT: 'non-mot',
    REPONSE_NON_FRANCAIS: 'pasfrancais',
    REPONSE_FRANCAIS: 'francais',
    IDENTIFICATION: 'identificationMot'
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

  def identification_mot
    nom == EVENEMENT[:IDENTIFICATION]
  end
end
