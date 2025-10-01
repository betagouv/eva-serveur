module Anonymisation
  class Compte < Anonymisation::Base
    def anonymise
      super do |compte|
        compte.prenom = FFaker::NameFR.first_name
        compte.nom = FFaker::NameFR.last_name
        compte.telephone = nil
        prefix_email = "#{compte.prenom.parameterize}.#{compte.nom.parameterize}.#{rand(999)}"
        compte.email = "#{prefix_email}@eva.fr"
        compte.skip_reconfirmation!
      end
    end
  end
end
