# frozen_string_literal: true

class Beneficiaire < ApplicationRecord
  has_many :evaluations, dependent: :destroy
  validates :nom, presence: true

  acts_as_paranoid

  def anonyme?
    anonymise_le.present?
  end

  def display_name
    nom
  end
end
