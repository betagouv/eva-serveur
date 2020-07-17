# frozen_string_literal: true

class Contact < ApplicationRecord
  belongs_to :saisi_par, class_name: 'Compte', foreign_key: 'compte_id'
  delegate :structure, to: :saisi_par
end
