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

  def svg_tag_base64(chemin_avec_extension, options = {})
    ## Ne pas oublier de rajouter l'extension au path sinon ça ne build pas en production

    raw = Rails.application.assets_manifest.find_sources(chemin_avec_extension).first
    image_tag svg_encode_en_base64(raw), alt: options[:alt], class: options[:class]
  end

  def cdn_for(fichier)
    return Rails.application.routes.url_helpers.url_for(fichier) unless Rails.env.production?

    param = "filename=#{fichier.filename}"
    "#{ENV.fetch('PROTOCOLE_SERVEUR')}://#{ENV.fetch('HOTE_STOCKAGE')}/#{fichier.key}?#{param}"
  end

  def svg_attachment_base64(attachment)
    return unless attachment.attached?

    file_content = attachment.download
    svg_encode_en_base64(file_content)
  end

  def inline_svg_content(attachment, options = {})
    return unless attachment.attached?

    file_content = attachment.download
    svg_with_class(file_content, options[:class])
  end

  def svg_encode_en_base64(file_content)
    encodage = Base64.strict_encode64 file_content
    "data:image/svg+xml;base64,#{encodage}"
  end

  def parse_svg_content(svg_content)
    content = svg_content.is_a?(Hash) && svg_content[:io] ? svg_content[:io].read : svg_content
    svg_content[:io].rewind if svg_content.is_a?(Hash) && svg_content[:io]
    Nokogiri::XML(content, nil, 'UTF-8')
  end

  def illustration_content_types
    %w[image/png image/jpeg image/webp].freeze
  end

  private

  def svg_with_class(svg_content, css_class)
    return svg_content if css_class.blank?

    svg_content.sub!('<svg', "<svg class=\"#{css_class}\"")
    svg_content.html_safe
  end
end
