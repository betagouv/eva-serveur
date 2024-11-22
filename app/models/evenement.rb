# frozen_string_literal: true

class Evenement < ApplicationRecord
  CODECLEA_METACOMPETENCE = {
    '2.1.1' => %w[operations_addition operations_soustraction operations_multiplication
                  operations_multiplication operations_division],
    '2.1.2' => %w[denombrement],
    '2.1.3' => %w[ordonner_nombres_entiers ordonner_nombres_decimaux operations_nombres_entiers],
    '2.1.4' => %w[estimation],
    '2.1.7' => %w[proportionnalite],
    '2.2.1' => %w[resolution_de_probleme],
    '2.2.2' => %w[pourcentages],
    '2.3.1' => %w[unites_temps unites_de_temps_conversions],
    '2.3.2' => %w[plannings plannings_calculs],
    '2.3.3' => %w[renseigner_horaires],
    '2.3.4' => %w[unites_de_mesure instruments_de_mesure],
    '2.3.5' => %w[tableaux_graphiques],
    '2.3.7' => %w[surfaces perimetres perimetres_surfaces volumes],
    '2.4.1' => %w[lecture_plan],
    '2.5.3' => %w[situation_dans_lespace reconnaitre_les_nombres reconaitre_les_nombres
                  vocabulaire_numeracie]
  }.freeze

  validates :nom, :date, :session_id, presence: true
  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :position, uniqueness: { scope: :session_id }
  # rubocop:enable Rails/UniqueValidationWithoutIndex
  belongs_to :partie, foreign_key: :session_id, primary_key: :session_id
  delegate :situation, :evaluation, to: :partie

  acts_as_paranoid

  scope :reponses, -> { where(nom: 'reponse') }

  def fin_situation?
    nom == 'finSituation'
  end

  def reponse_intitule
    donnees['reponseIntitule'].presence || donnees['reponse']
  end

  def code_clea
    metacompetence = donnees['metacompetence']
    return if metacompetence.blank?

    CODECLEA_METACOMPETENCE.find do |_, metacompetences|
      metacompetences.include?(metacompetence)
    end&.first
  end
end
