# frozen_string_literal: true

class Campagne < ApplicationRecord
  has_many :situations_configurations, -> { order(position: :asc) }, dependent: :destroy
  belongs_to :questionnaire, optional: true
  belongs_to :compte
  belongs_to :parcours_type, optional: true
  default_scope { order(created_at: :asc) }

  validates :libelle, presence: true
  validates :code, presence: true, uniqueness: true

  accepts_nested_attributes_for :situations_configurations, allow_destroy: true
  accepts_nested_attributes_for :compte

  before_create :initialise_situations, if: :parcours_type_id
  after_create :programme_email_relance

  scope :de_la_structure, lambda { |structure|
    joins(:compte).where('comptes.structure_id' => structure)
  }

  def display_name
    libelle
  end

  def questionnaire_pour(situation)
    situations_configurations.find_by(situation: situation)&.questionnaire_utile
  end

  private

  def initialise_situations
    parcours_type.situations_configurations.each do |situation_configuration|
      situations_configurations.build situation_id: situation_configuration.situation_id
    end
  end

  def programme_email_relance
    RelanceUtilisateurPourCampagneJob.set(wait: 30.days).perform_later(campagne: self)
  end
end
