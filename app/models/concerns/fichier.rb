module Fichier
  extend ActiveSupport::Concern
  def nom_fichier_horodate(titre, extension)
    nom_fichier(DateTime.current, titre, extension, "%Y%m%d%H%M%S")
  end

  def nom_fichier(date, titre, extension, format = "%Y%m%d-%H%M")
    "#{date.strftime(format)}-#{titre}.#{extension}"
  end
end
