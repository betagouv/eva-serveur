module EtapeInscriptionHelper
  def redirige_vers_etape_inscription(compte)
    redirect_to etape_inscription_path(compte.etape_inscription)
  end

  private

  def etape_inscription_path(etape)
    case etape
    when "nouveau"
      new_compte_registration_path
    when "preinscription"
      inscription_informations_compte_path
    when "recherche_structure"
      admin_recherche_structure_path
    when "assignation_structure"
      inscription_structure_path
    when "complet"
      admin_dashboard_path
    end
  end
end
