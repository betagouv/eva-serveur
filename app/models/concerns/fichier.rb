# frozen_string_literal: true

module Fichier
  extend ActiveSupport::Concern
  def nom_fichier_horodate(titre, extension)
    date = DateTime.current.strftime("%Y%m%d%H%M%S")
    "#{date}-#{titre}.#{extension}"
  end

  def nom_fichier_date(date, titre, extension)
    "#{date.strftime("%Y%m%d")}-#{titre}.#{extension}"
  end
end
