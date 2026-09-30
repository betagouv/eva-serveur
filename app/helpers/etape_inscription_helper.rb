module EtapeInscriptionHelper
  def redirige_vers_etape_inscription(compte)
    redirect_to etape_inscription_path(compte.etape_inscription)
  end

  private

  def etape_inscription_path(etape)
    case etape
    when "preinscription"
      inscription_informations_compte_path
    when "recherche_structure"
      inscription_recherche_structure_path
    when "assignation_structure"
      inscription_structure_path
    # Un compte à l'étape "nouveau" est déjà connecté, il n'a donc pas à repasser
    # par la création de compte (inscription/nouveau_compte le renverrait ici).
    when "nouveau", "complet"
      admin_dashboard_path
    end
  end
end
