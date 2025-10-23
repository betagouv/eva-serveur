class ParcoursType < ApplicationRecord
  self.implicit_order_column = "created_at"
  TYPES_DE_PROGRAMME = %i[diagnostic positionnement diagnostic_entreprise].freeze

  validates :libelle, :duree_moyenne, presence: true
  validates :nom_technique, presence: true, uniqueness: true

  has_many :situations_configurations, lambda {
                                         order(position: :asc)
                                       }, dependent: :destroy
  accepts_nested_attributes_for :situations_configurations, allow_destroy: true

  enum :type_de_programme, TYPES_DE_PROGRAMME.zip(TYPES_DE_PROGRAMME.map(&:to_s)).to_h

  acts_as_paranoid

  def self.types_programmes_eva
    %i[diagnostic positionnement]
  end

  def diagnostic_entreprise?
    type_de_programme.to_sym == :diagnostic_entreprise
  end

  def display_name
    libelle
  end

  def option_redaction?
    situations_configurations.map(&:nom_technique).include?("livraison")
  end
end
