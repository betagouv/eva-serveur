# frozen_string_literal: true

module Restitution
  class Securite < Base
    BONNE_QUALIFICATION = 'bonne'
    IDENTIFICATION_POSITIVE = 'oui'
    DANGERS_TOTAL = 5

    EVENEMENT = {
      QUALIFICATION_DANGER: 'qualificationDanger',
      IDENTIFICATION_DANGER: 'identificationDanger',
      ACTIVATION_AIDE_1: 'activationAide'
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
      return nombre_dangers_identifies if timestamp_activation_aide.blank?

      dangers_identifies_tries = dangers_identifies.partition do |danger|
        danger.date < timestamp_activation_aide
      end
      dangers_identifies_tries.first.length
    end

    def nombre_retours_non_dangers_identifies
      identifications_par_non_danger.inject(0) do |memo, (_danger, identifications)|
        memo + identifications.count - 1
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

    def dangers_identifies
      evenements.select { |e| est_un_danger_identifie?(e) }
    end

    def est_un_danger_identifie?(evenement)
      evenement.nom == EVENEMENT[:IDENTIFICATION_DANGER] &&
        evenement.donnees['reponse'] == IDENTIFICATION_POSITIVE &&
        evenement.donnees['danger'].present?
    end

    def est_un_non_danger_identifie?(evenement)
      evenement.nom == EVENEMENT[:IDENTIFICATION_DANGER] &&
        evenement.donnees['danger'].blank?
    end

    def identifications_par_non_danger
      identifications_non_danger = evenements.select { |e| est_un_non_danger_identifie?(e) }
      identifications_non_danger.group_by { |e| e.donnees['zone'] }
    end

    def timestamp_activation_aide
      evenements.select { |e| e.nom == EVENEMENT[:ACTIVATION_AIDE_1] }
                .pluck(:date)
                .join
    end
  end
end
