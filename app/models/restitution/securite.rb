# frozen_string_literal: true

module Restitution
  class Securite < Base
    BONNE_QUALIFICATION = 'bonne'
    IDENTIFICATION_POSITIVE = 'oui'
    DANGERS_TOTAL = 5

    EVENEMENT = {
      QUALIFICATION_DANGER: 'qualificationDanger',
      IDENTIFICATION_DANGER: 'identificationDanger'
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

    def nombre_dangers_identifies
      evenements.count do |e|
        e.nom == EVENEMENT[:IDENTIFICATION_DANGER] &&
          e.donnees['reponse'] == IDENTIFICATION_POSITIVE &&
          e.donnees['danger'].present?
      end
    end

    def nombre_retours_deja_qualifies
      qualifications_par_danger.inject(0) do |memo, (_danger, qualifications)|
        memo + qualifications.count - 1
      end
    end

    private

    def bonne_reponse?(evenement)
      evenement.donnees['reponse'] == BONNE_QUALIFICATION
    end

    def qualifications_par_danger
      qualifications_dangers = evenements.select { |e| e.nom == EVENEMENT[:QUALIFICATION_DANGER] }
      qualifications_dangers.group_by { |e| e.donnees['danger'] }
    end
  end
end
