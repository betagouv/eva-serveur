# frozen_string_literal: true

class Question < ApplicationRecord
  has_one_attached :illustration

  validates :intitule, :libelle, :nom_technique, presence: true

  acts_as_paranoid

  def display_name
    libelle
  end
end
