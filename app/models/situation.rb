# frozen_string_literal: true

class Situation < ApplicationRecord
  SITUATIONS_COMPETENCES_TRANSVERSALES = %w[controle inventaire securite tri].freeze
  SITUATIONS_PRE_POSITIONNEMENT = %w[maintenance livraison objets_trouves].freeze
  SITUATIONS_POSITIONNEMENT = %w[cafe_de_la_place].freeze

  validates :libelle, presence: true
  validates :nom_technique, presence: true, uniqueness: true

  has_one_attached :illustration
  belongs_to :questionnaire, optional: true
  belongs_to :questionnaire_entrainement, optional: true, class_name: 'Questionnaire'

  delegate :livraison_sans_redaction?, to: :questionnaire, allow_nil: true

  BIENVENUE = 'bienvenue'
  CAFE_DE_LA_PLACE = 'cafe_de_la_place'
  PLAN_DE_LA_VILLE = 'plan_de_la_ville'
  COULEURS_BORDURES = ['#6E85FD', '#82ABE8', '#8FC6DA', '#9FD9C9', '#ABCE8F', '#DFBC78', '#FBAF55',
                       '#FD8554', '#FD5965', '#FD586D'].freeze

  acts_as_paranoid

  def display_name
    libelle
  end

  def as_json(_options = nil)
    slice(:id, :libelle, :nom_technique, :questionnaire_id, :questionnaire_entrainement_id)
  end

  def bienvenue?
    nom_technique == BIENVENUE
  end
end
