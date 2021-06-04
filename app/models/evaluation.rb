# frozen_string_literal: true

class Evaluation < ApplicationRecord
  validates :nom, presence: true
  belongs_to :campagne, counter_cache: :nombre_evaluations
  attr_accessor :code_campagne

  before_validation :trouve_campagne_depuis_code
  validate :code_campagne_connu

  def display_name
    nom
  end

  scope :de_la_structure, lambda { |structure|
    joins(campagne: :compte).where('comptes.structure_id' => structure)
  }

  def anonyme?
    anonymise_le.present?
  end

  private

  def trouve_campagne_depuis_code
    return if code_campagne.blank?

    self.campagne = Campagne.par_code(code_campagne).take
  end

  def code_campagne_connu
    return if code_campagne.blank? || campagne.present?

    errors.add(:code_campagne, :inconnu)
  end
end
