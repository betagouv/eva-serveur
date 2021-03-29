# frozen_string_literal: true

class Compte < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :registerable
  validates :role, inclusion: { in: %w[administrateur organisation] }
  validates :statut_validation, presence: true
  validates_presence_of :nom, :prenom, on: :create
  default_scope { order(created_at: :asc) }

  enum statut_validation: %i[en_attente acceptee refusee], _prefix: :validation

  belongs_to :structure

  accepts_nested_attributes_for :structure

  def display_name
    [nom_complet, email].reject(&:blank?).join(' - ')
  end

  def nom_complet
    [prenom, nom].reject(&:blank?).join(' ')
  end

  def administrateur?
    role == 'administrateur'
  end
end
