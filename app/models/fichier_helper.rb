# frozen_string_literal: true

class FichierHelper
  class << self
    def nom_fichier_horodate(titre, extension)
      date = DateTime.current.strftime('%Y%m%d%H%M%S')
      "#{date}-#{titre}.#{extension}"
    end
  end
end
