class Opco < ApplicationRecord
  validates :nom, presence: true
  validate :url_offre_services_doit_etre_une_url_http_ou_https
  scope :financeurs, -> { where(financeur: true) }
  before_validation :normalise_idcc

  has_one_attached :logo do |attachable|
    attachable.variant :defaut,
                       resize_to_limit: [ 500, 500 ],
                       preprocessed: true
  end

  has_one_attached :visuel_offre_services do |attachable|
    attachable.variant :offre_services,
                       resize_to_fill: [ 640, 180 ],
                       preprocessed: true
  end

  attr_accessor :supprimer_visuel_offre_services, :idcc_texte

  after_update :supprime_visuel_offre_services

  def display_name
    nom
  end

  def slug
    nom
      &.unicode_normalize(:nfkd)
      &.encode("ASCII", replace: "")
      &.downcase
      &.gsub(/[^a-z0-9\s-]/, "")
      &.gsub(/\s+/, "") || ""
  end

  def logo_url
    cdn_for(logo)
  end

  private

  def supprime_visuel_offre_services
    visuel_offre_services.purge_later if supprime_visuel_offre_services?
  end

  def supprime_visuel_offre_services?
    visuel_offre_services.attached? &&
      supprimer_visuel_offre_services == "1" &&
      !nouveau_visuel_offre_services?
  end

  def nouveau_visuel_offre_services?
    attachment_changes && attachment_changes["visuel_offre_services"].present?
  end

  def url_offre_services_doit_etre_une_url_http_ou_https
    return if url_offre_services.blank?

    uri = URI.parse(url_offre_services)
    return if uri.is_a?(URI::HTTP) && uri.host.present?

    errors.add(:url_offre_services, :invalid)
  rescue URI::InvalidURIError
    errors.add(:url_offre_services, :invalid)
  end

  def normalise_idcc
    valeurs_brutes = if idcc_texte.present?
      idcc_texte.split(",")
    else
      Array(idcc).flat_map { |value| value.to_s.split(/[,\n]/) }
    end

    self.idcc = valeurs_brutes
      .map { |value| normalise_valeur_idcc(value) }
      .reject(&:blank?)
      .uniq
  end

  def normalise_valeur_idcc(value)
    str = value.to_s.strip
    return str unless str.match?(/\A\d+\z/)

    str.rjust(4, "0")
  end
end
