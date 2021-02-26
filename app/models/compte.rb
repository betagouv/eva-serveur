# frozen_string_literal: true

class Compte < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  validates :role, inclusion: { in: %w[administrateur organisation] }
  default_scope { order(created_at: :asc) }

  belongs_to :structure

  accepts_nested_attributes_for :structure

  def display_name
    email
  end

  def administrateur?
    role == 'administrateur'
  end
end
