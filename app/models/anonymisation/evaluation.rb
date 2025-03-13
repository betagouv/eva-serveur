# frozen_string_literal: true

module Anonymisation
  class Evaluation < Anonymisation::Base
    def anonymise(nouveau_nom = nil)
      super do |evaluation|
        evaluation.nom = nouveau_nom.presence || FFaker::NameFR.name
        evaluation.email = nil
        evaluation.telephone = nil
      end
    end
  end
end
