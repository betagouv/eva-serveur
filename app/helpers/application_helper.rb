# frozen_string_literal: true

module ApplicationHelper
  include CampagneHelper
  include MarkdownHelper
  include SituationHelper

  def formate_efficience(nombre)
    return I18n.t("admin.restitutions.evaluation.#{nombre}") if nombre.is_a?(Symbol)

    number_to_percentage(nombre, precision: 0)
  end

  def formate_duree(duree)
    return if duree.blank?

    signe = duree.negative? ? '-' : ''
    duree = duree.to_i.abs
    heure_minutes_secondes = [duree / 3600, duree / 60 % 60, duree % 60]
    heure_minutes_secondes.shift if heure_minutes_secondes[0].zero?
    "#{signe}#{heure_minutes_secondes.map { |t| t.to_s.rjust(2, '0') }.join(':')}"
  end

  def rapport_colonne_class
    'col-4 px-5 mb-4'
  end

  def svg_tag_base64(path_with_extension, options = {})
    ## Ne pas oublier de rajouter l'extension au path sinon ça ne build pas en production

    raw = Rails.application.assets_manifest.find_sources(path_with_extension).first
    encode_svg_file(raw, options)
  end

  def cdn_for(fichier)
    return Rails.application.routes.url_helpers.url_for(fichier) unless Rails.env.production?

    param = "filename=#{fichier.filename}"
    "#{ENV.fetch('PROTOCOLE_SERVEUR')}://#{ENV.fetch('HOTE_STOCKAGE')}/#{fichier.key}?#{param}"
  end

  def svg_attachment_base64(attachment, options = {})
    return unless attachment.attached?

    file_content = attachment.download
    encode_svg_file(file_content, options)
  end

  private

  def encode_svg_file(file_content, options)
    encodage = Base64.strict_encode64 file_content
    image_src64 = "data:image/svg+xml;base64,#{encodage}"
    image_tag image_src64, options
  end
end
