# frozen_string_literal: true

module Restitution
  class Securite < Base
    BONNE_REPONSE = 'bonne'
    DANGERS_TOTAL = 5

    EVENEMENT = {
      QUALIFICATION_DANGER: 'qualificationDanger'
    }.freeze

    def termine?
      qualifications_par_danger.count == DANGERS_TOTAL
    end

    def nombre_bien_qualifies
      qualifications_finales = qualifications_par_danger.map do |_danger, qualifications|
        qualifications.max_by(&:created_at)
      end
      qualifications_finales.count { |e| bonne_reponse?(e) }
    end

    private

    def bonne_reponse?(evenement)
      evenement.donnees['reponse'] == BONNE_REPONSE
    end

    def qualifications_par_danger
      qualifications_dangers = evenements.select { |e| e.nom == EVENEMENT[:QUALIFICATION_DANGER] }
      qualifications_dangers.group_by { |e| e.donnees['danger'] }
    end
  end
end
