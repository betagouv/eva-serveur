class CampagneCompteAutorisation < ApplicationRecord
  belongs_to :compte

  acts_as_paranoid
end
