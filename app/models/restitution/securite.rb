# frozen_string_literal: true

module Restitution
  class Securite < AvecEntrainement
    DANGERS_TOTAL = 5

    EVENEMENT = {
      ACTIVATION_AIDE_1: 'activationAide'
    }.freeze

    def initialize(campagne, evenements)
      evenements = evenements.map { |e| EvenementSecuriteDecorator.new e }
      super(campagne, evenements)
    end

    def termine?
      super || qualifications_par_danger.count == DANGERS_TOTAL
    end

    def persiste
      metriques = %i[
        nombre_reouverture_zone_sans_danger nombre_bien_qualifies
        nombre_dangers_bien_identifies nombre_retours_deja_qualifies
        nombre_dangers_bien_identifies_avant_aide_1 attention_visuo_spatiale
        temps_ouvertures_zones_dangers temps_moyen_ouvertures_zones_dangers
        temps_entrainement temps_total nombre_rejoue_consigne nombre_danger_mal_identifies
      ].each_with_object({}) do |methode, memo|
        memo[methode] = public_send(methode)
      end
      partie.update(metriques: metriques)
    end

    def nombre_bien_qualifies
      qualifications_par_danger.map do |_danger, qualifications|
        qualifications.max_by(&:created_at)
      end.count(&:bonne_reponse?)
    end

    def nombre_dangers_bien_identifies
      dangers_bien_identifies.count
    end

    def nombre_danger_mal_identifies
      dangers_mal_identifies.count
    end

    def nombre_retours_deja_qualifies
      qualifications_par_danger.inject(0) do |memo, (_danger, qualifications)|
        memo + qualifications.count - 1
      end
    end

    def nombre_dangers_bien_identifies_avant_aide_1
      return nombre_dangers_bien_identifies if activation_aide1.blank?

      dangers_bien_identifies_tries = dangers_bien_identifies.partition do |danger|
        danger.date < activation_aide1.date
      end
      dangers_bien_identifies_tries.first.length
    end

    def attention_visuo_spatiale
      identification = dangers_bien_identifies.find(&:danger_visuo_spatial?)
      return ::Competence::NIVEAU_INDETERMINE if identification.blank?

      if activation_aide1.present? && activation_aide1.date < identification.date
        return ::Competence::APTE_AVEC_AIDE
      end

      ::Competence::APTE
    end

    def nombre_reouverture_zone_sans_danger
      evenements_situation.select(&:ouverture_zone_sans_danger?)
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

    def qualifications_par_danger
      evenements_situation.select(&:qualification_danger?).group_by { |e| e.donnees['danger'] }
    end

    def dangers_bien_identifies
      @dangers_bien_identifies ||= evenements_situation.select(&:est_un_danger_bien_identifie?)
    end

    def dangers_mal_identifies
      @dangers_mal_identifies ||= evenements_situation.select(&:est_un_danger_mal_identifie?)
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

        selectionne = e.demarrage? || e.qualification_danger? || e.ouverture_zone_danger?
        dernier_evenement_retenu = e if selectionne
        selectionne
      end
    end
  end
end
