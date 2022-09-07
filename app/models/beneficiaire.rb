# frozen_string_literal: true

class Beneficiaire < ApplicationRecord
  has_many :evaluations, dependent: :nullify
  validates :nom, presence: true

  def anonyme?
    anonymise_le.present?
  end

  def display_name
    nom
  end
end
