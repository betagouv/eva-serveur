# frozen_string_literal: true

class Beneficiaire < ApplicationRecord
  has_one :evaluation

  def display_name
    nom
  end
end
