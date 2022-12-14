# frozen_string_literal: true

module Comptes
  module PriseEnMain
    extend ActiveSupport::Concern

    included do
      const_set(
        :ETAPES_PRISE_EN_MAIN,
        %w[creation_campagne test_campagne passations retour_experience].freeze
      )
      enum :etape_prise_en_main, ETAPES_PRISE_EN_MAIN.zip(ETAPES_PRISE_EN_MAIN).to_h
    end

    def numero_etape
      return 0 if etape_prise_en_main == creation_campagne
      return 1 if etape_prise_en_main == test_campagne
      return 2 if etape_prise_en_main == passations

      3
    end
  end
end
