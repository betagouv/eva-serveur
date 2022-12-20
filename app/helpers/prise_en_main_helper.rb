# frozen_string_literal: true

module PriseEnMainHelper
  def statut_etape(numero_etape, etape_en_cours)
    case numero_etape
    when etape_en_cours
      'active'
    when 0..etape_en_cours
      'succes'
    else
      'desactive'
    end
  end
end
