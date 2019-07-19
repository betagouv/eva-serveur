# frozen_string_literal: true

class Choix < ApplicationRecord
  validates :intitule, :type_choix, presence: true
  enum type_choix: %i[bon mauvais abstention]

  acts_as_list scope: :question_id
end
