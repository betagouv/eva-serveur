class Opco < ApplicationRecord
  validates :nom, presence: true

  has_one_attached :logo do |attachable|
    attachable.variant :defaut,
                       resize_to_limit: [ 500, 500 ],
                       preprocessed: true
  end

  def display_name
    nom
  end
end
