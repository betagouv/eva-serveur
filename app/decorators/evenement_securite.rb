class EvenementSecurite < SimpleDelegator
  BONNE_QUALIFICATION = "bonne"
  IDENTIFICATION_POSITIVE = "oui"
  DANGER_VISUO_SPATIAL = "signalisation"

  EVENEMENT = {
    QUALIFICATION_DANGER: "qualificationDanger",
    IDENTIFICATION_DANGER: "identificationDanger",
    OUVERTURE_ZONE: "ouvertureZone"
  }.freeze

  def demarrage?
    nom == Restitution::MetriquesHelper::EVENEMENT[:DEMARRAGE]
  end

  def bonne_reponse?
    donnees["reponse"] == BONNE_QUALIFICATION
  end

  def est_un_danger_bien_identifie?
    est_un_danger_identifie?(bonne_reponse: true)
  end

  def est_un_danger_mal_identifie?
    est_un_danger_identifie?(bonne_reponse: false)
  end

  def ouverture_zone_sans_danger?
    ouverture_zone? && !donnees["danger"]
  end

  def ouverture_zone_danger?
    ouverture_zone? && donnees["danger"].present?
  end

  def ouverture_zone?
    nom == EVENEMENT[:OUVERTURE_ZONE]
  end

  def qualification_danger?
    nom == EVENEMENT[:QUALIFICATION_DANGER]
  end

  def danger_visuo_spatial?
    donnees["danger"] == DANGER_VISUO_SPATIAL
  end

  def bonne_qualification_danger?
    qualification_danger? && bonne_reponse?
  end

  private

  def est_un_danger_identifie?(bonne_reponse:)
    comparateur = bonne_reponse ? :== : :!=
    nom == EVENEMENT[:IDENTIFICATION_DANGER] &&
      donnees["reponse"].send(comparateur, IDENTIFICATION_POSITIVE) &&
      donnees["danger"].present?
  end
end
