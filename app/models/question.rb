# frozen_string_literal: true

class Question < ApplicationRecord
  has_one_attached :illustration

  validates :intitule, presence: true
  validates :libelle, presence: true

  def display_name
    libelle
  end
end
