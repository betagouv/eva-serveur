# frozen_string_literal: true

class Metacompetence
  CORRESPONDANCES_CODECLEA = {
    "2.1" => {
      "2.1.1" => %w[operations_addition operations_soustraction operations_multiplication
                    operations_division],
      "2.1.2" => %w[denombrement],
      "2.1.3" => %w[ordonner_nombres_entiers ordonner_nombres_decimaux],
      "2.1.4" => %w[estimation],
      "2.1.5" => %w[],
      "2.1.6" => %w[],
      "2.1.7" => %w[proportionnalite]
    },
    "2.2" => {
      "2.2.1" => %w[resolution_de_probleme],
      "2.2.2" => %w[pourcentages]
    },
    "2.3" => {
      "2.3.1" => %w[unites_de_temps unites_de_temps_conversions],
      "2.3.2" => %w[plannings_lecture plannings_calculs],
      "2.3.3" => %w[renseigner_horaires],
      "2.3.4" => %w[unites_de_mesure instruments_de_mesure],
      "2.3.5" => %w[tableaux_graphiques],
      "2.3.6" => %w[],
      "2.3.7" => %w[surfaces perimetres volumes]
    },
    "2.4" => {
      "2.4.1" => %w[lecture_plan]
    },
    "2.5" => {
      "2.5.1" => %w[],
      "2.5.2" => %w[],
      "2.5.3" => %w[situation_dans_lespace reconnaitre_les_nombres vocabulaire_numeracie]
    }
  }.freeze

  CODECLEA_INTITULES = {
    "2.1" => I18n.t("activerecord.metacompetence.codes_clea.2_1"),
    "2.2" => I18n.t("activerecord.metacompetence.codes_clea.2_2"),
    "2.3" => I18n.t("activerecord.metacompetence.codes_clea.2_3"),
    "2.4" => I18n.t("activerecord.metacompetence.codes_clea.2_4"),
    "2.5" => I18n.t("activerecord.metacompetence.codes_clea.2_5"),
    "2.1.1" => I18n.t("activerecord.metacompetence.codes_clea.2_1_1"),
    "2.1.2" => I18n.t("activerecord.metacompetence.codes_clea.2_1_2"),
    "2.1.3" => I18n.t("activerecord.metacompetence.codes_clea.2_1_3"),
    "2.1.4" => I18n.t("activerecord.metacompetence.codes_clea.2_1_4"),
    "2.1.5" => I18n.t("activerecord.metacompetence.codes_clea.2_1_5"),
    "2.1.6" => I18n.t("activerecord.metacompetence.codes_clea.2_1_6"),
    "2.1.7" => I18n.t("activerecord.metacompetence.codes_clea.2_1_7"),
    "2.2.1" => I18n.t("activerecord.metacompetence.codes_clea.2_2_1"),
    "2.2.2" => I18n.t("activerecord.metacompetence.codes_clea.2_2_2"),
    "2.3.1" => I18n.t("activerecord.metacompetence.codes_clea.2_3_1"),
    "2.3.2" => I18n.t("activerecord.metacompetence.codes_clea.2_3_2"),
    "2.3.3" => I18n.t("activerecord.metacompetence.codes_clea.2_3_3"),
    "2.3.4" => I18n.t("activerecord.metacompetence.codes_clea.2_3_4"),
    "2.3.5" => I18n.t("activerecord.metacompetence.codes_clea.2_3_5"),
    "2.3.6" => I18n.t("activerecord.metacompetence.codes_clea.2_3_6"),
    "2.3.7" => I18n.t("activerecord.metacompetence.codes_clea.2_3_7"),
    "2.4.1" => I18n.t("activerecord.metacompetence.codes_clea.2_4_1"),
    "2.5.1" => I18n.t("activerecord.metacompetence.codes_clea.2_5_1"),
    "2.5.2" => I18n.t("activerecord.metacompetence.codes_clea.2_5_2"),
    "2.5.3" => I18n.t("activerecord.metacompetence.codes_clea.2_5_3")
  }.freeze

  METACOMPETENCES_NUMERATIE = CORRESPONDANCES_CODECLEA.values.flat_map(&:values).flatten.freeze

  class << self
    def code_clea_sous_domaine(metacompetence)
      recupere_codes_clea(metacompetence)&.first
    end

    def code_clea_sous_sous_domaine(metacompetence)
      recupere_codes_clea(metacompetence)&.last&.find do |_, metacompetences|
        metacompetences.include?(metacompetence)
      end&.first
    end

    def metacompetences_pour_code(code)
      return metacompetences_par_code[code] if CORRESPONDANCES_CODECLEA.key?(code)

      metacompetences_par_sous_code[code]
    end

    def metacompetences_par_code
      @metacompetences_par_code ||= begin
        CORRESPONDANCES_CODECLEA.transform_values do |sous_codes|
          sous_codes.values.flatten
        end
      end
    end

    def metacompetences_par_sous_code
      @metacompetences_par_sous_code ||= begin
        CORRESPONDANCES_CODECLEA.each_with_object({}) do |(_, sous_codes), result|
          sous_codes.each do |sous_code, metacompetences|
            result[sous_code] = metacompetences
          end
        end
      end
    end

    def recupere_codes_clea(metacompetence)
      CORRESPONDANCES_CODECLEA.find do |_, metacompetences|
        metacompetences.values.flatten.include?(metacompetence)
      end
    end
  end
end
