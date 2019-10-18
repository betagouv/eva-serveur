# frozen_string_literal: true

module Restitution
  class Securite < Base
    BONNE_QUALIFICATION = 'bonne'
    IDENTIFICATION_POSITIVE = 'oui'
    DANGERS_TOTAL = 5

    EVENEMENT = {
      QUALIFICATION_DANGER: 'qualificationDanger',
      IDENTIFICATION_DANGER: 'identificationDanger',
      ACTIVATION_AIDE_1: 'activationAide',
      DEMARRAGE: 'demarrage'
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
      dangers_identifies.count
    end

    def nombre_retours_deja_qualifies
      qualifications_par_danger.inject(0) do |memo, (_danger, qualifications)|
        memo + qualifications.count - 1
      end
    end

    def nombre_dangers_identifies_avant_aide_1
      return nombre_dangers_identifies if timestamp_pour(EVENEMENT[:ACTIVATION_AIDE_1]).blank?

      dangers_identifies_tries = dangers_identifies.partition do |danger|
        danger.date < timestamp_pour(EVENEMENT[:ACTIVATION_AIDE_1])
      end
      dangers_identifies_tries.first.length
    end

    def temps_identification_premier_danger
      return 0 if timestamp_premier_danger_identifie.blank?

      delta_en_seconde = timestamp_premier_danger_identifie - timestamp_pour(EVENEMENT[:DEMARRAGE])
      Time.at(delta_en_seconde).strftime('%M:%S')
    end

    private

    def bonne_reponse?(evenement)
      evenement.donnees['reponse'] == BONNE_QUALIFICATION
    end

    def qualifications_par_danger
      qualifications_dangers = evenements.select { |e| e.nom == EVENEMENT[:QUALIFICATION_DANGER] }
      qualifications_dangers.group_by { |e| e.donnees['danger'] }
    end

    def dangers_identifies
      evenements.select { |e| est_un_danger_identifie?(e) }
    end

    def est_un_danger_identifie?(evenement)
      evenement.nom == EVENEMENT[:IDENTIFICATION_DANGER] &&
        evenement.donnees['reponse'] == IDENTIFICATION_POSITIVE &&
        evenement.donnees['danger'].present?
    end

    def timestamp_pour(evenement)
      evenements.select { |e| e.nom == evenement }
                .pluck(:date)
                .first
    end

    def timestamp_premier_danger_identifie
      dangers_identifies = evenements.select do |e|
        e.nom == EVENEMENT[:IDENTIFICATION_DANGER] &&
          e.donnees['danger'].present?
      end
      return dangers_identifies if dangers_identifies.blank?

      dangers_identifies.first.date
    end
  end
end
