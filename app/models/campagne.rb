# frozen_string_literal: true

class Campagne < ApplicationRecord
  has_many :evaluations
  has_many :situations_configurations, -> { order(position: :asc) }
  belongs_to :questionnaire, optional: true

  validates :libelle, presence: true
  validates :code, presence: true, uniqueness: true
  before_validation :genere_code_unique

  def display_name
    libelle
  end

  private

  def genere_code_unique
    return if self[:code].present?

    loop do
      self[:code] = SecureRandom.hex 3
      break if Campagne.where(code: self[:code]).none?
    end
  end
end
