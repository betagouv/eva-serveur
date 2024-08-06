# frozen_string_literal: true

class Question < ApplicationRecord
  validates :libelle, :nom_technique, presence: true
  has_many :transcriptions, dependent: :destroy

  accepts_nested_attributes_for :transcriptions, allow_destroy: true,
                                                 reject_if: :reject_transcriptions

  CATEGORIE = %i[situation scolarite sante appareils].freeze
  enum :categorie, CATEGORIE.zip(CATEGORIE.map(&:to_s)).to_h, prefix: true

  acts_as_paranoid

  def display_name
    [categorie, libelle].compact.join(' : ')
  end

  private

  def reject_transcriptions(attributes)
    attributes['audio'].blank? && attributes['ecrit'].blank? && new_record?
  end
end
