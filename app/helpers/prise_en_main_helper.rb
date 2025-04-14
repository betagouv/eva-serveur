# frozen_string_literal: true

module PriseEnMainHelper
  def statut_etape(etape, etape_en_cours)
    index_etape = PriseEnMain::ETAPES.find_index(etape)
    index_etape_en_cours = PriseEnMain::ETAPES.find_index(etape_en_cours)
    case index_etape
    when index_etape_en_cours
      "active"
    when 0..index_etape_en_cours
      "succes"
    else
      "desactive"
    end
  end

  def passations_restantes(nombre)
    "#{nombre} #{nombre == 1 ? 'passation' : 'passations'}"
  end
end
