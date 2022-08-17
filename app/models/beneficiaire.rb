# frozen_string_literal: true

class Beneficiaire < ApplicationRecord
  has_one :evaluation, dependent: :nullify

  def display_name
    nom
  end
end
