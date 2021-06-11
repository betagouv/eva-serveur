# frozen_string_literal: true

module Anonymisation
  class Compte < Anonymisation::Base
    def anonymise
      super do |compte|
        compte.prenom = FFaker::NameFR.first_name
        compte.nom = FFaker::NameFR.last_name
        compte.telephone = nil
        compte.email = "#{compte.prenom.parameterize}.#{compte.nom.parameterize}@eva.beta.gouv.fr"
      end
    end
  end
end