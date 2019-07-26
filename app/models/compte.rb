# frozen_string_literal: true

class Compte < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  validates :role, inclusion: { in: %w[administrateur organisation] }, presence: true
end
