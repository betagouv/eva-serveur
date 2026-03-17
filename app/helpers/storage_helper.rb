module StorageHelper
  def cdn_for(fichier)
    return Rails.application.routes.url_helpers.url_for(fichier) unless Rails.env.production?

    param = "filename=#{fichier.filename}"
    "#{ENV.fetch('PROTOCOLE_SERVEUR')}://#{ENV.fetch('HOTE_STOCKAGE')}/#{fichier.key}?#{param}"
  end

  def apercu_piece_jointe_avec_lien(piece_jointe, variant:, alt: nil,
classe_image: "image-preview", fallback: nil)
    return content_tag(:span, fallback) unless piece_jointe.attached?

    texte_alt = alt.presence || (piece_jointe.respond_to?(:filename) ? piece_jointe.filename : nil)
    link_to cdn_for(piece_jointe), target: "_blank", rel: "noopener" do
      image_tag(
        cdn_for(piece_jointe.variant(variant)),
        alt: texte_alt,
        class: classe_image
      )
    end
  end
end
