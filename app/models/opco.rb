class Opco < ApplicationRecord
  validates :nom, presence: true
  validate :url_offre_services_doit_etre_une_url_http_ou_https
  scope :financeurs, -> { where(financeur: true) }

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

  def url_offre_services_doit_etre_une_url_http_ou_https
    return if url_offre_services.blank?

    uri = URI.parse(url_offre_services)
    return if uri.is_a?(URI::HTTP) && uri.host.present?

    errors.add(:url_offre_services, :invalid)
  rescue URI::InvalidURIError
    errors.add(:url_offre_services, :invalid)
  end
end
