# frozen_string_literal: true

class Campagne < ApplicationRecord
  validates :libelle, presence: true
  validates :code, presence: true, uniqueness: true
end
