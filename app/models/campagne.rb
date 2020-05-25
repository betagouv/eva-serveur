# frozen_string_literal: true

class Campagne < ApplicationRecord
  has_many :situations_configurations, -> { order(position: :asc) }, dependent: :destroy
  has_many :situations, through: :situations_configurations
  belongs_to :questionnaire, optional: true
  belongs_to :compte
  default_scope { order(created_at: :asc) }

  validates :libelle, presence: true
  validates :code, presence: true, uniqueness: true
  before_validation :genere_code_unique

  accepts_nested_attributes_for :situations_configurations, allow_destroy: true
  accepts_nested_attributes_for :compte

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
