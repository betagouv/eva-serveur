# frozen_string_literal: true

class Beneficiaire < ApplicationRecord
  def display_name
    nom
  end
end
