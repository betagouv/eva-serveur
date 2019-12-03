# frozen_string_literal: true

module Restitution
  class Securite < AvecEntrainement
    BONNE_QUALIFICATION = 'bonne'
    IDENTIFICATION_POSITIVE = 'oui'
    DANGERS_TOTAL = 5
    DANGER_VISUO_SPATIAL = 'signalisation'

    EVENEMENT = {
      QUALIFICATION_DANGER: 'qualificationDanger',
      IDENTIFICATION_DANGER: 'identificationDanger',
      ACTIVATION_AIDE_1: 'activationAide',
      OUVERTURE_ZONE: 'ouvertureZone'
    }.freeze

    def termine?
      super || qualifications_par_danger.count == DANGERS_TOTAL
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
      return nombre_dangers_identifies if activation_aide1.blank?

      dangers_identifies_tries = dangers_identifies.partition do |danger|
        danger.date < activation_aide1.date
      end
      dangers_identifies_tries.first.length
    end

    def attention_visuo_spatiale
      identification = dangers_identifies.find { |e| e.donnees['danger'] == DANGER_VISUO_SPATIAL }
      return ::Competence::NIVEAU_INDETERMINE if identification.blank?

      if activation_aide1.present? && activation_aide1.date < identification.date
        return ::Competence::APTE_AVEC_AIDE
      end

      ::Competence::APTE
    end

    def nombre_reouverture_zone_sans_danger
      ouverture_zones_sans_dangers = evenements_situation.select do |e|
        e.nom == EVENEMENT[:OUVERTURE_ZONE] && !e.donnees['danger']
      end
      ouverture_zones_sans_dangers
        .group_by { |e| e.donnees['zone'] }
        .inject(0) do |memo, (_danger, ouvertures)|
          memo + ouvertures.count - 1
        end
    end

    def temps_ouvertures_zones_dangers
      les_temps = []
      evenements_demarrage_ouvertures_et_qualifications.each_slice(2) do |e1, e2|
        next if e2.blank?

        les_temps << e2.date - e1.date
      end
      les_temps
    end

    def temps_moyen_ouvertures_zones_dangers
      return nil if temps_ouvertures_zones_dangers.empty?

      temps_ouvertures_zones_dangers.sum / temps_ouvertures_zones_dangers.size
    end

    private

    def bonne_reponse?(evenement)
      evenement.donnees['reponse'] == BONNE_QUALIFICATION
    end

    def qualifications_par_danger
      qualifications_dangers = evenements_situation.select do |e|
        e.nom == EVENEMENT[:QUALIFICATION_DANGER]
      end
      qualifications_dangers.group_by { |e| e.donnees['danger'] }
    end

    def dangers_identifies
      evenements_situation.select { |e| est_un_danger_identifie?(e) }
    end

    def est_un_danger_identifie?(evenement)
      evenement.nom == EVENEMENT[:IDENTIFICATION_DANGER] &&
        evenement.donnees['reponse'] == IDENTIFICATION_POSITIVE &&
        evenement.donnees['danger'].present?
    end

    def activation_aide1
      @activation_aide1 ||= premier_evenement_du_nom(
        evenements_situation,
        EVENEMENT[:ACTIVATION_AIDE_1]
      )
    end

    def evenements_demarrage_ouvertures_et_qualifications
      dernier_evenement_retenu = nil
      evenements_situation.select do |e|
        next if dernier_evenement_retenu&.nom == e.nom

        selectionne = [AvecEntrainement::EVENEMENT[:DEMARRAGE],
                       EVENEMENT[:QUALIFICATION_DANGER]].include?(e.nom) ||
                      e.nom == EVENEMENT[:OUVERTURE_ZONE] && e.donnees['danger'].present?
        dernier_evenement_retenu = e if selectionne
        selectionne
      end
    end
  end
end
