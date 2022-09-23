# frozen_string_literal: true

class ParcoursType < ApplicationRecord
  self.implicit_order_column = 'created_at'

  validates :libelle, :duree_moyenne, presence: true
  validates :nom_technique, presence: true, uniqueness: true

  has_many :situations_configurations, lambda {
                                         order(position: :asc)
                                       }, dependent: :destroy
  accepts_nested_attributes_for :situations_configurations, allow_destroy: true

  def display_name
    libelle
  end

  def option_redaction?
    situations_configurations.map(&:nom_technique).include?('livraison')
  end
end
