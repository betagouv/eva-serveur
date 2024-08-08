# frozen_string_literal: true

class Question < ApplicationRecord
  validates :libelle, :nom_technique, :type, presence: true

  CATEGORIE = %i[situation scolarite sante appareils].freeze
  TYPES = %i[QuestionQcm QuestionSaisie QuestionSousConsigne].freeze
  enum :type, TYPES.zip(TYPES.map(&:to_s)).to_h
  enum :categorie, CATEGORIE.zip(CATEGORIE.map(&:to_s)).to_h, prefix: true

  has_many :choix, lambda {
    order(position: :asc)
  }, foreign_key: :question_id,
     dependent: :destroy

  accepts_nested_attributes_for :choix, allow_destroy: true

  acts_as_paranoid

  def display_name
    [categorie, libelle].compact.join(' : ')
  end
end
