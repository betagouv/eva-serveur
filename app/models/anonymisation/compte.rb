module Anonymisation
  class Compte < Anonymisation::Base
    def anonymise
      super do |compte|
        compte.prenom = FFaker::NameFR.first_name
        compte.nom = FFaker::NameFR.last_name
        prefix_email = "#{compte.prenom.parameterize}.#{compte.nom.parameterize}.#{rand(999)}"
        compte.email = "#{prefix_email}@anlci.gouv.fr"
        efface_donnees_personnelles(compte)
        compte.skip_reconfirmation!
      end
    end

    def efface_donnees_personnelles(compte)
        compte.telephone = nil
        compte.id_pro_connect = nil
        compte.id_inclusion_connect = nil
        compte.fonction = nil
        compte.service_departement = nil
    end
  end
end
