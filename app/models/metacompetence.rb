# frozen_string_literal: true

class Metacompetence
  CORRESPONDANCES_CODECLEA = {
    '2.1' => {
      '2.1.1' => %w[operations_addition operations_soustraction operations_multiplication
                    operations_division],
      '2.1.2' => %w[denombrement],
      '2.1.3' => %w[ordonner_nombres_entiers ordonner_nombres_decimaux operations_nombres_entiers],
      '2.1.4' => %w[estimation],
      '2.1.7' => %w[proportionnalite]
    },
    '2.2' => {
      '2.2.1' => %w[resolution_de_probleme],
      '2.2.2' => %w[pourcentages]
    },
    '2.3' => {
      '2.3.1' => %w[unites_temps unites_de_temps_conversions],
      '2.3.2' => %w[plannings plannings_calculs],
      '2.3.3' => %w[renseigner_horaires],
      '2.3.4' => %w[unites_de_mesure instruments_de_mesure],
      '2.3.5' => %w[tableaux_graphiques],
      '2.3.7' => %w[surfaces perimetres perimetres_surfaces volumes]
    },
    '2.4' => {
      '2.4.1' => %w[lecture_plan]
    },
    '2.5' => {
      '2.5.3' => %w[situation_dans_lespace reconnaitre_les_nombres reconaitre_les_nombres
                    vocabulaire_numeracie]
    }
  }.freeze

  CODECLEA_INTITULES = {
    '2.1' => I18n.t('activerecord.metacompetence.codes_clea.2_1'),
    '2.2' => I18n.t('activerecord.metacompetence.codes_clea.2_2'),
    '2.3' => I18n.t('activerecord.metacompetence.codes_clea.2_3'),
    '2.4' => I18n.t('activerecord.metacompetence.codes_clea.2_4'),
    '2.5' => I18n.t('activerecord.metacompetence.codes_clea.2_5')
  }.freeze

  METACOMPETENCES_BASE = %w[numeratie ccf syntaxe-orthographe].freeze
  METACOMPETENCES_NUMERATIE = CORRESPONDANCES_CODECLEA.values.flat_map(&:values).flatten.freeze

  METACOMPETENCES = (METACOMPETENCES_BASE + METACOMPETENCES_NUMERATIE).freeze

  def initialize(metacompetence)
    @metacompetence = metacompetence
  end

  def code_clea_sous_domaine
    recupere_codes_clea&.first
  end

  def code_clea_sous_sous_domaine
    recupere_codes_clea&.last&.find do |_, metacompetences|
      metacompetences.include?(@metacompetence)
    end&.first
  end

  private

  def recupere_codes_clea
    CORRESPONDANCES_CODECLEA.find do |_, metacompetences|
      metacompetences.values.flatten.include?(@metacompetence)
    end
  end
end
