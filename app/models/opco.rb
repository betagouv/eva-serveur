class Opco < ApplicationRecord
  validates :nom, presence: true
  scope :financeurs, -> { where(financeur: true) }

  has_one_attached :logo do |attachable|
    attachable.variant :defaut,
                       resize_to_limit: [ 500, 500 ],
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
end
