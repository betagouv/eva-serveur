# frozen_string_literal: true

module Restitution
  class Securite < Base
    BONNE_REPONSE = 'bonne'

    EVENEMENT = {
      QUALIFICATION_DANGER: 'qualificationDanger'
    }.freeze

    def nombre_bonnes_qualifications
      evenements.count { |e| e.nom == EVENEMENT[:QUALIFICATION_DANGER] && bonne_reponse?(e) }
    end

    private

    def bonne_reponse?(evenement)
      evenement.donnees['reponse'] == BONNE_REPONSE
    end
  end
end
