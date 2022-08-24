# frozen_string_literal: true

class Beneficiaire < ApplicationRecord
  validates :nom, presence: true

  def display_name
    nom
  end
end
