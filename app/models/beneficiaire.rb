# frozen_string_literal: true

class Beneficiaire < ApplicationRecord
  has_many :evaluations, dependent: :destroy
  validates :nom, presence: true
  acts_as_paranoid

  scope :le_plus_ancien, -> { order(created_at: :asc).first }
  scope :sauf_pour, ->(id) { where.not(id: id) }

  def anonyme?
    anonymise_le.present?
  end

  def display_name
    nom
  end
end
