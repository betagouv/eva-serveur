# frozen_string_literal: true

class Question < ApplicationRecord
  validates :intitule, :libelle, :nom_technique, presence: true

  CATEGORIE = %i[situation scolarite sante appareils].freeze
  enum :categorie, CATEGORIE.zip(CATEGORIE.map(&:to_s)).to_h, prefix: true

  acts_as_paranoid

  def display_name
    [categorie, libelle].compact.join(' : ')
  end
end
