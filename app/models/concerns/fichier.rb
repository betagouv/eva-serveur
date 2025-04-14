# frozen_string_literal: true

module Fichier
  extend ActiveSupport::Concern
  def nom_fichier_horodate(titre, extension)
    date = DateTime.current.strftime("%Y%m%d%H%M%S")
    "#{date}-#{titre}.#{extension}"
  end
end
