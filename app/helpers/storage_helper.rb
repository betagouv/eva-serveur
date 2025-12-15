module StorageHelper
  def cdn_for(fichier)
    return Rails.application.routes.url_helpers.url_for(fichier) unless Rails.env.production?

    param = "filename=#{fichier.filename}"
    "#{ENV.fetch('PROTOCOLE_SERVEUR')}://#{ENV.fetch('HOTE_STOCKAGE')}/#{fichier.key}?#{param}"
  end
end
