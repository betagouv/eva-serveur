# frozen_string_literal: true

module Anonymisation
  class Beneficiaire < Anonymisation::Base
    def anonymise(nouveau_nom = nil)
      super do |beneficiaire|
        beneficiaire.nom = nouveau_nom.presence || FFaker::NameFR.name
      end
    end
  end
end
