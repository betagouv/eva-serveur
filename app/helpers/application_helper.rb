module ApplicationHelper
  include CampagneHelper
  include MarkdownHelper
  include SituationHelper
  include StorageHelper

  def formate_efficience(nombre)
    return I18n.t("admin.restitutions.evaluation.#{nombre}") if nombre.is_a?(Symbol)

    number_to_percentage(nombre, precision: 0)
  end

  def formate_duree(duree)
    return if duree.blank?

    signe = duree.negative? ? "-" : ""
    duree = duree.to_i.abs
    heure_minutes_secondes = [ duree / 3600, duree / 60 % 60, duree % 60 ]
    heure_minutes_secondes.shift if heure_minutes_secondes[0].zero?
    "#{signe}#{heure_minutes_secondes.map { |t| t.to_s.rjust(2, '0') }.join(':')}"
  end

  def rapport_colonne_class
    "col-4 px-5 mb-4"
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
    Nokogiri::XML(content, nil, "UTF-8")
  end

  def illustration_content_types
    %w[image/png image/jpeg image/webp].freeze
  end

  def partenaires_opcos_financeurs(compte)
    return [] if compte.blank?

    opco_financeur = StructureOpco.opco_financeur_pour_structure_id(compte.structure_id)

    return [] unless opco_financeur.present? && opco_financeur.logo.attached?

    [ { logo: cdn_for(opco_financeur.logo), nom: opco_financeur.nom, url: opco_financeur.url } ]
  end

  private

  def svg_with_class(svg_content, css_class)
    return svg_content if css_class.blank?

    svg_content.sub!("<svg", "<svg class=\"#{css_class}\"")
    svg_content.html_safe
  end
end
