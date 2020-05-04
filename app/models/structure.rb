# frozen_string_literal: true

class Structure < ApplicationRecord
  validates :nom, :code_postal, presence: true

  def display_name
    nom
  end
end
