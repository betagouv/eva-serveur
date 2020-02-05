# frozen_string_literal: true

class Situation < ApplicationRecord
  validates :libelle, presence: true
  validates :nom_technique, presence: true, uniqueness: true
  belongs_to :questionnaire, optional: true

  def display_name
    libelle
  end

  def as_json(_options = nil)
    slice(:id, :libelle, :nom_technique, :questionnaire_id)
  end
end
